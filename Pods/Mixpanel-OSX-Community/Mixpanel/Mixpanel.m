#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag on this file.
#endif

#include <arpa/inet.h>
#include <ifaddrs.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <sys/socket.h>
#include <sys/sysctl.h>

#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonDigest.h>
#if TARGET_OS_IPHONE
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <SystemConfiguration/SystemConfiguration.h>
#endif
#import <SystemConfiguration/SystemConfiguration.h>

#import "Mixpanel.h"
#import "NSData+MPBase64.h"

#ifndef IFT_ETHER
#define IFT_ETHER 0x6 // ethernet CSMACD
#endif

#define VERSION @"2.3.6"

#ifdef MIXPANEL_LOG
#define MixpanelLog(...) NSLog(__VA_ARGS__)
#else
#define MixpanelLog(...)
#endif

#ifdef MIXPANEL_DEBUG
#define MixpanelDebug(...) NSLog(__VA_ARGS__)
#else
#define MixpanelDebug(...)
#endif

@interface Mixpanel () {
    NSUInteger _flushInterval;
}

// re-declare internally as readwrite
@property (atomic, strong) MixpanelPeople *people;
@property (atomic, copy) NSString *distinctId;

@property (nonatomic, copy) NSString *apiToken;
@property (atomic, strong) NSDictionary *superProperties;
@property (atomic, strong) NSDictionary *automaticProperties;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSMutableArray *eventsQueue;
@property (nonatomic, strong) NSMutableArray *peopleQueue;
@property dispatch_queue_t serialQueue;
@property (nonatomic, assign) SCNetworkReachabilityRef reachability;
#if TARGET_OS_IPHONE
@property (nonatomic, strong) CTTelephonyNetworkInfo *telephonyInfo;
#endif
@property (nonatomic, strong) NSDateFormatter *dateFormatter;


@end

@interface MixpanelPeople ()

@property (nonatomic, weak) Mixpanel *mixpanel;
@property (nonatomic, strong) NSMutableArray *unidentifiedQueue;
@property (nonatomic, copy) NSString *distinctId;
@property (nonatomic, strong) NSDictionary *automaticPeopleProperties;

- (id)initWithMixpanel:(Mixpanel *)mixpanel;

@end

static NSString *MPURLEncode(NSString *s)
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)s, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8));
}

@implementation Mixpanel

static void MixpanelReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info)
{
    if (info != NULL && [(__bridge NSObject*)info isKindOfClass:[Mixpanel class]]) {
        @autoreleasepool {
            Mixpanel *mixpanel = (__bridge Mixpanel *)info;
            [mixpanel reachabilityChanged:flags];
        }
    } else {
        NSLog(@"Mixpanel reachability callback received unexpected info object");
    }
}

static Mixpanel *sharedInstance = nil;

+ (Mixpanel *)sharedInstanceWithToken:(NSString *)apiToken
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super alloc] initWithToken:apiToken andFlushInterval:60];
    });
    return sharedInstance;
}

+ (Mixpanel *)sharedInstance
{
    if (sharedInstance == nil) {
        NSLog(@"%@ warning sharedInstance called before sharedInstanceWithToken:", self);
    }
    return sharedInstance;
}

- (instancetype)initWithToken:(NSString *)apiToken andFlushInterval:(NSUInteger)flushInterval
{
    if (apiToken == nil) {
        apiToken = @"";
    }
    if ([apiToken length] == 0) {
        NSLog(@"%@ warning empty api token", self);
    }
    if (self = [self init]) {
        self.people = [[MixpanelPeople alloc] initWithMixpanel:self];
        self.apiToken = apiToken;
        _flushInterval = flushInterval;
        self.flushOnBackground = YES;
        self.showNetworkActivityIndicator = YES;
        self.serverURL = @"https://api.mixpanel.com";


        self.distinctId = [self defaultDistinctId];
        self.superProperties = [NSMutableDictionary dictionary];
        self.automaticProperties = [self collectAutomaticProperties];
        self.eventsQueue = [NSMutableArray array];
        self.peopleQueue = [NSMutableArray array];
        NSString *label = [NSString stringWithFormat:@"com.mixpanel.%@.%p", apiToken, self];
        _serialQueue = dispatch_queue_create([label UTF8String], DISPATCH_QUEUE_SERIAL);
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        [_dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];


        // wifi reachability
        BOOL reachabilityOk = NO;
        if ((_reachability = SCNetworkReachabilityCreateWithName(NULL, "api.mixpanel.com")) != NULL) {
            SCNetworkReachabilityContext context = {0, (__bridge void*)self, NULL, NULL, NULL};
            if (SCNetworkReachabilitySetCallback(_reachability, MixpanelReachabilityCallback, &context)) {
                if (SCNetworkReachabilitySetDispatchQueue(_reachability, _serialQueue)) {
                    reachabilityOk = YES;
                    MixpanelDebug(@"%@ successfully set up reachability callback", self);
                } else {
                    // cleanup callback if setting dispatch queue failed
                    SCNetworkReachabilitySetCallback(_reachability, NULL, NULL);
                }
            }
        }
        if (!reachabilityOk) {
            NSLog(@"%@ failed to set up reachability callback: %s", self, SCErrorString(SCError()));
        }

        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

        // cellular info
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            [self setCurrentRadio];
            [notificationCenter addObserver:self
                                   selector:@selector(setCurrentRadio)
                                       name:CTRadioAccessTechnologyDidChangeNotification
                                     object:nil];
        }
#endif

#if TARGET_OS_IPHONE == 0 // OS X
        [notificationCenter addObserver:self
                               selector:@selector(applicationWillTerminate:)
                                   name:NSApplicationWillTerminateNotification
                                 object:nil];
        [notificationCenter addObserver:self
                               selector:@selector(applicationWillResignActive:)
                                   name:NSApplicationWillResignActiveNotification
                                 object:nil];
        [notificationCenter addObserver:self
                               selector:@selector(applicationDidBecomeActive:)
                                   name:NSApplicationDidBecomeActiveNotification
                                 object:nil];
#endif
        [self unarchive];
    }

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_reachability != NULL) {
        if (!SCNetworkReachabilitySetCallback(_reachability, NULL, NULL)) {
            NSLog(@"%@ error unsetting reachability callback", self);
        }
        if (!SCNetworkReachabilitySetDispatchQueue(_reachability, NULL)) {
            NSLog(@"%@ error unsetting reachability dispatch queue", self);
        }
        CFRelease(_reachability);
        _reachability = NULL;
        MixpanelDebug(@"realeased reachability");
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<Mixpanel: %p %@>", self, self.apiToken];
}

- (NSString *)deviceModel
{
    size_t size;
    sysctlbyname("hw.model", NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname("hw.model", answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding:NSUTF8StringEncoding];
    
    free(answer);
    return results;

}

- (NSString *)IFA
{
    NSString *ifa = nil;
#ifndef MIXPANEL_NO_IFA
    Class ASIdentifierManagerClass = NSClassFromString(@"ASIdentifierManager");
    if (ASIdentifierManagerClass) {
        SEL sharedManagerSelector = NSSelectorFromString(@"sharedManager");
        id sharedManager = ((id (*)(id, SEL))[ASIdentifierManagerClass methodForSelector:sharedManagerSelector])(ASIdentifierManagerClass, sharedManagerSelector);
        SEL advertisingIdentifierSelector = NSSelectorFromString(@"advertisingIdentifier");
        NSUUID *uuid = ((NSUUID* (*)(id, SEL))[sharedManager methodForSelector:advertisingIdentifierSelector])(sharedManager, advertisingIdentifierSelector);
        ifa = [uuid UUIDString];
    }
#endif
    return ifa;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
- (void)setCurrentRadio
{
    dispatch_async(self.serialQueue, ^(){
        NSMutableDictionary *properties = [self.automaticProperties mutableCopy];
        properties[@"$radio"] = [self currentRadio];
        self.automaticProperties = [properties copy];
    });
}

- (NSString *)currentRadio
{
    NSString *radio = _telephonyInfo.currentRadioAccessTechnology;
    if (!radio) {
        radio = @"None";
    } else if ([radio hasPrefix:@"CTRadioAccessTechnology"]) {
        radio = [radio substringFromIndex:23];
    }
    return radio;
}
#endif

- (NSDictionary *)collectAutomaticProperties
{
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    
#if TARGET_OS_IPHONE
    UIDevice *device = [UIDevice currentDevice];
    NSString *deviceModel = [self deviceModel];
    CGSize size = [UIScreen mainScreen].bounds.size;
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    
    [properties setValue:@"iphone" forKey:@"mp_lib"];
    [properties setValue:VERSION forKey:@"$lib_version"];
    [properties setValue:[[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"] forKey:@"$app_version"];
    [properties setValue:[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] forKey:@"$app_release"];
    [properties setValue:@"Apple" forKey:@"$manufacturer"];
    [properties setValue:[device systemName] forKey:@"$os"];
    [properties setValue:[device systemVersion] forKey:@"$os_version"];
    [properties setValue:deviceModel forKey:@"$model"];
    [properties setValue:deviceModel forKey:@"mp_device_model"]; // legacy
    [properties setValue:@((NSInteger)size.height) forKey:@"$screen_height"];
    [properties setValue:@((NSInteger)size.width) forKey:@"$screen_width"];
    [properties setValue:[self IFA] forKey:@"$ios_ifa"];
    [properties setValue:carrier.carrierName forKey:@"$carrier"];
#else
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    
    [properties setValue:@"mac" forKey:@"mp_lib"];
    [properties setValue:VERSION forKey:@"$lib_version"];
    
    [properties setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"$app_version"];
    
    [properties setValue:@"Apple" forKey:@"$manufacturer"];
    [properties setValue:@"Mac OS X" forKey:@"$os"];
    [properties setValue:[processInfo operatingSystemVersionString] forKey:@"$os_version"];
    
    [properties setValue:[self deviceModel] forKey:@"$model"];
    [properties setValue:[self deviceModel] forKey:@"mp_device_model"]; // legacy
    
    NSSize size = [NSScreen mainScreen].frame.size;
    [properties setValue:[NSNumber numberWithInt:(int)size.height] forKey:@"$screen_height"];
    [properties setValue:[NSNumber numberWithInt:(int)size.width] forKey:@"$screen_width"];
#endif

    return [properties copy];
}

+ (BOOL)inBackground
{
#if TARGET_OS_IPHONE
    return [UIApplication sharedApplication].applicationState == UIApplicationStateBackground;
#else
    BOOL inBg = NO;
    inBg = ![[NSRunningApplication currentApplication] isActive];

    return inBg;
#endif
}

+ (NSDictionary *)interfaces
{
    NSMutableDictionary *theDictionary = [NSMutableDictionary dictionary];
    
    BOOL success;
    struct ifaddrs * addrs;
    const struct ifaddrs * cursor;
    const struct sockaddr_dl * dlAddr;
    const uint8_t * base;
    
    success = getifaddrs(&addrs) == 0;
    if (success) {
        cursor = addrs;
        while (cursor != NULL) {
            if ((cursor->ifa_addr->sa_family == AF_LINK) && (((const struct sockaddr_dl *)cursor->ifa_addr)->sdl_type == IFT_ETHER)) {
                // fprintf(stderr, "%s:", cursor->ifa_name);
                dlAddr = (const struct sockaddr_dl *)cursor->ifa_addr;
                base = (const uint8_t *) &dlAddr->sdl_data[dlAddr->sdl_nlen];
                
                NSString *theKey = [NSString stringWithUTF8String:cursor->ifa_name];
                NSString *theValue = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", base[0], base[1], base[2], base[3], base[4], base[5]];
                [theDictionary setObject:theValue forKey:theKey];
            }
            
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return(theDictionary);
}

+ (NSString *)uniqueDeviceString
{
    NSDictionary *dict = [Mixpanel interfaces];
    NSArray *keys = [dict allKeys];
    keys = [keys  sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    NSString *bundleName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleNameKey];
    
    // while most apps will define CFBundleName, it's not guaranteed;
    // an app can choose to define it or not so when it's missing, use the bundle file name
    if (bundleName == nil) {
        bundleName = [[[NSBundle mainBundle] bundlePath] lastPathComponent];
    }
    
    NSMutableString *string = [NSMutableString stringWithString:bundleName];
    for (NSString *key in keys) {
        [string appendString:[dict objectForKey:key]];
    }
    return string;
}

#pragma mark - Encoding/decoding utilities

- (NSData *)JSONSerializeObject:(id)obj
{
    id coercedObj = [self JSONSerializableObjectForObject:obj];
    NSError *error = nil;
    NSData *data = nil;
    @try {
        data = [NSJSONSerialization dataWithJSONObject:coercedObj options:0 error:&error];
    }
    @catch (NSException *exception) {
        NSLog(@"%@ exception encoding api data: %@", self, exception);
    }
    if (error) {
        NSLog(@"%@ error encoding api data: %@", self, error);
    }
    return data;
}

- (id)JSONSerializableObjectForObject:(id)obj
{
    // valid json types
    if ([obj isKindOfClass:[NSString class]] ||
        [obj isKindOfClass:[NSNumber class]] ||
        [obj isKindOfClass:[NSNull class]]) {
        return obj;
    }
    // recurse on containers
    if ([obj isKindOfClass:[NSArray class]]) {
        NSMutableArray *a = [NSMutableArray array];
        for (id i in obj) {
            [a addObject:[self JSONSerializableObjectForObject:i]];
        }
        return [NSArray arrayWithArray:a];
    }
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *d = [NSMutableDictionary dictionary];
        for (id key in obj) {
            NSString *stringKey;
            if (![key isKindOfClass:[NSString class]]) {
                stringKey = [key description];
                NSLog(@"%@ warning: property keys should be strings. got: %@. coercing to: %@", self, [key class], stringKey);
            } else {
                stringKey = [NSString stringWithString:key];
            }
            id v = [self JSONSerializableObjectForObject:[obj objectForKey:key]];
            [d setObject:v forKey:stringKey];
        }
        return [NSDictionary dictionaryWithDictionary:d];
    }
    // some common cases
    if ([obj isKindOfClass:[NSDate class]]) {
        return [self.dateFormatter stringFromDate:obj];
    } else if ([obj isKindOfClass:[NSURL class]]) {
        return [obj absoluteString];
    }
    // default to sending the object's description
    NSString *s = [obj description];
    NSLog(@"%@ warning: property values should be valid json types. got: %@. coercing to: %@", self, [obj class], s);
    return s;
}

- (NSString *)encodeAPIData:(NSArray *)array
{
    NSString *b64String = @"";
    NSData *data = [self JSONSerializeObject:array];
    if (data) {
        b64String = [data mp_base64EncodedString];
        b64String = (id)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                (__bridge CFStringRef)b64String,
                                                                NULL,
                                                                CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                kCFStringEncodingUTF8));
    }
    return b64String;
}

+ (NSString *)calculateHMACSHA1withString:(NSString *)str andKey:(NSString *)key
{
    const char *cStr = [str UTF8String];
    const char *cSecretStr = [key UTF8String];
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    memset((void *)digest, 0x0, CC_SHA1_DIGEST_LENGTH);
    CCHmac(kCCHmacAlgSHA1, cSecretStr, strlen(cSecretStr), cStr, strlen(cStr), digest);
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            digest[0],  digest[1],  digest[2],  digest[3],
            digest[4],  digest[5],  digest[6],  digest[7],
            digest[8],  digest[9],  digest[10], digest[11],
            digest[12], digest[13], digest[14], digest[15],
            digest[16], digest[17], digest[18], digest[19]
            ];
}

#pragma mark - Tracking

+ (void)assertPropertyTypes:(NSDictionary *)properties
{
    for (id k in properties) {
        NSAssert([k isKindOfClass: [NSString class]], @"%@ property keys must be NSString. got: %@ %@", self, [k class], k);
        // would be convenient to do: id v = [properties objectForKey:k]; ..but, when the NSAssert's are stripped out in release, it becomes an unused variable error
        NSAssert([[properties objectForKey:k] isKindOfClass:[NSString class]] ||
                 [[properties objectForKey:k] isKindOfClass:[NSNumber class]] ||
                 [[properties objectForKey:k] isKindOfClass:[NSNull class]] ||
                 [[properties objectForKey:k] isKindOfClass:[NSArray class]] ||
                 [[properties objectForKey:k] isKindOfClass:[NSDictionary class]] ||
                 [[properties objectForKey:k] isKindOfClass:[NSDate class]] ||
                 [[properties objectForKey:k] isKindOfClass:[NSURL class]],
                 @"%@ property values must be NSString, NSNumber, NSNull, NSArray, NSDictionary, NSDate or NSURL. got: %@ %@", self, [[properties objectForKey:k] class], [properties objectForKey:k]);
    }
}

- (NSString *)defaultDistinctId
{
    return [Mixpanel calculateHMACSHA1withString:[Mixpanel uniqueDeviceString] andKey:self.apiToken];
}


- (void)identify:(NSString *)distinctId
{
    if (distinctId == nil || distinctId.length == 0) {
        NSLog(@"%@ error blank distinct id: %@", self, distinctId);
        return;
    }
    dispatch_async(_serialQueue, ^{
        self.distinctId = distinctId;
        self.people.distinctId = distinctId;
        if ([self.people.unidentifiedQueue count] > 0) {
            for (NSMutableDictionary *r in self.people.unidentifiedQueue) {
                [r setObject:distinctId forKey:@"$distinct_id"];
                [self.peopleQueue addObject:r];
            }
            [self.people.unidentifiedQueue removeAllObjects];
            [self archivePeople];
        }
        if ([Mixpanel inBackground]) {
            [self archiveProperties];
        }
    });
}

- (void)createAlias:(NSString *)alias forDistinctID:(NSString *)distinctID
{
    if (!alias || [alias length] == 0) {
        NSLog(@"%@ create alias called with empty alias: %@", self, alias);
        return;
    }
    if (!distinctID || [distinctID length] == 0) {
        NSLog(@"%@ create alias called with empty distinct id: %@", self, distinctID);
        return;
    }
    [self track:@"$create_alias" properties:@{@"distinct_id": distinctID, @"alias": alias}];
}

- (void)track:(NSString *)event
{
    [self track:event properties:nil];
}

- (void)track:(NSString *)event properties:(NSDictionary *)properties
{
    if (event == nil || [event length] == 0) {
        NSLog(@"%@ mixpanel track called with empty event parameter. using 'mp_event'", self);
        event = @"mp_event";
    }
    properties = [properties copy];
    [Mixpanel assertPropertyTypes:properties];
    NSNumber *epochSeconds = @(round([[NSDate date] timeIntervalSince1970]));
    dispatch_async(_serialQueue, ^{
        NSMutableDictionary *p = [NSMutableDictionary dictionary];
        [p addEntriesFromDictionary:self.automaticProperties];
        [p setObject:self.apiToken forKey:@"token"];
        [p setObject:epochSeconds forKey:@"time"];
        if (self.nameTag) {
            [p setObject:self.nameTag forKey:@"mp_name_tag"];
        }
        if (self.distinctId) {
            [p setObject:self.distinctId forKey:@"distinct_id"];
        }
        [p addEntriesFromDictionary:self.superProperties];
        if (properties) {
            [p addEntriesFromDictionary:properties];
        }
        NSDictionary *e = @{@"event": event, @"properties": [NSDictionary dictionaryWithDictionary:p]};
        MixpanelLog(@"%@ queueing event: %@", self, e);
        [self.eventsQueue addObject:e];
        if ([self.eventsQueue count] > 500) {
            [self.eventsQueue removeObjectAtIndex:0];
        }
        if ([Mixpanel inBackground]) {
            [self archiveEvents];
        }
    });
}

- (void)registerSuperProperties:(NSDictionary *)properties
{
    properties = [properties copy];
    [Mixpanel assertPropertyTypes:properties];
    dispatch_async(_serialQueue, ^{
        NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:self.superProperties];
        [tmp addEntriesFromDictionary:properties];
        self.superProperties = [NSDictionary dictionaryWithDictionary:tmp];
        if ([Mixpanel inBackground]) {
            [self archiveProperties];
        }
    });
}

- (void)registerSuperPropertiesOnce:(NSDictionary *)properties
{
    properties = [properties copy];
    [Mixpanel assertPropertyTypes:properties];
    dispatch_async(_serialQueue, ^{
        NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:self.superProperties];
        for (NSString *key in properties) {
            if ([tmp objectForKey:key] == nil) {
                [tmp setObject:[properties objectForKey:key] forKey:key];
            }
        }
        self.superProperties = [NSDictionary dictionaryWithDictionary:tmp];
        if ([Mixpanel inBackground]) {
            [self archiveProperties];
        }
    });
}

- (void)registerSuperPropertiesOnce:(NSDictionary *)properties defaultValue:(id)defaultValue
{
    properties = [properties copy];
    [Mixpanel assertPropertyTypes:properties];
    dispatch_async(_serialQueue, ^{
        NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:self.superProperties];
        for (NSString *key in properties) {
            id value = [tmp objectForKey:key];;
            if (value == nil || [value isEqual:defaultValue]) {
                [tmp setObject:[properties objectForKey:key] forKey:key];
            }
        }
        self.superProperties = [NSDictionary dictionaryWithDictionary:tmp];
        if ([Mixpanel inBackground]) {
            [self archiveProperties];
        }
    });
}

- (void)unregisterSuperProperty:(NSString *)propertyName
{
    dispatch_async(_serialQueue, ^{
        NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:self.superProperties];
        if ([tmp objectForKey:propertyName] != nil) {
            [tmp removeObjectForKey:propertyName];
        }
        self.superProperties = [NSDictionary dictionaryWithDictionary:tmp];
        if ([Mixpanel inBackground]) {
            [self archiveProperties];
        }
    });
}

- (void)clearSuperProperties
{
    dispatch_async(_serialQueue, ^{
        self.superProperties = @{};
        if ([Mixpanel inBackground]) {
            [self archiveProperties];
        }
    });
}

- (NSDictionary *)currentSuperProperties
{
    return [self.superProperties copy];
}

- (void)reset
{
    dispatch_async(_serialQueue, ^{
        self.distinctId = [self defaultDistinctId];
        self.nameTag = nil;
        self.superProperties = [NSMutableDictionary dictionary];
        self.people.distinctId = nil;
        self.people.unidentifiedQueue = [NSMutableArray array];
        self.eventsQueue = [NSMutableArray array];
        self.peopleQueue = [NSMutableArray array];
        [self archive];
    });
}

#pragma mark - Network control

- (NSUInteger)flushInterval
{
    @synchronized(self) {
        return _flushInterval;
    }
}

- (void)setFlushInterval:(NSUInteger)interval
{
    @synchronized(self) {
        _flushInterval = interval;
    }
    [self startFlushTimer];
}

- (void)startFlushTimer
{
    [self stopFlushTimer];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.flushInterval > 0) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:self.flushInterval
                                                          target:self
                                                        selector:@selector(flush)
                                                        userInfo:nil
                                                         repeats:YES];
            MixpanelDebug(@"%@ started flush timer: %@", self, self.timer);
        }
    });
}

- (void)stopFlushTimer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.timer) {
            [self.timer invalidate];
            MixpanelDebug(@"%@ stopped flush timer: %@", self, self.timer);
        }
        self.timer = nil;
    });
}

- (void)flush
{
    dispatch_async(_serialQueue, ^{
        MixpanelDebug(@"%@ flush starting", self);

        __strong id<MixpanelDelegate> strongDelegate = _delegate;
        if (strongDelegate != nil && [strongDelegate respondsToSelector:@selector(mixpanelWillFlush:)] && ![strongDelegate mixpanelWillFlush:self]) {
            MixpanelDebug(@"%@ flush deferred by delegate", self);
            return;
        }

        [self flushEvents];
        [self flushPeople];

        MixpanelDebug(@"%@ flush complete", self);
    });
}

- (void)flushEvents
{
    [self flushQueue:_eventsQueue
            endpoint:@"/track/"];
}

- (void)flushPeople
{
    [self flushQueue:_peopleQueue
            endpoint:@"/engage/"];
}

- (void)flushQueue:(NSMutableArray *)queue endpoint:(NSString *)endpoint
{
    while ([queue count] > 0) {
        NSUInteger batchSize = ([queue count] > 50) ? 50 : [queue count];
        NSArray *batch = [queue subarrayWithRange:NSMakeRange(0, batchSize)];

        NSString *requestData = [self encodeAPIData:batch];
        NSString *postBody = [NSString stringWithFormat:@"ip=1&data=%@", requestData];
        MixpanelDebug(@"%@ flushing %lu of %lu to %@: %@", self, (unsigned long)[batch count], (unsigned long)[queue count], endpoint, queue);
        NSURLRequest *request = [self apiRequestWithEndpoint:endpoint andBody:postBody];
        NSError *error = nil;


        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];


        if (error) {
            NSLog(@"%@ network failure: %@", self, error);
            break;
        }

        NSString *response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        if ([response intValue] == 0) {
            NSLog(@"%@ %@ api rejected some items", self, endpoint);
        };

        [queue removeObjectsInArray:batch];
    }
}


- (void)reachabilityChanged:(SCNetworkReachabilityFlags)flags
{
    // this should be run in the serial queue. the reason we don't dispatch_async here
    // is because it's only ever called by the reachability callback, which is already
    // set to run on the serial queue. see SCNetworkReachabilitySetDispatchQueue in init
    BOOL wifi = (flags & kSCNetworkReachabilityFlagsReachable) && !(flags & kSCNetworkReachabilityFlagsIsDirect);
    NSMutableDictionary *properties = [self.automaticProperties mutableCopy];
    [properties setObject:[NSNumber numberWithBool:wifi] forKey:@"$wifi"];
    self.automaticProperties = [properties copy];
    MixpanelDebug(@"%@ reachability changed, wifi=%d", self, wifi);
}

- (NSURLRequest *)apiRequestWithEndpoint:(NSString *)endpoint andBody:(NSString *)body
{
    NSURL *URL = [NSURL URLWithString:[self.serverURL stringByAppendingString:endpoint]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    MixpanelDebug(@"%@ http request: %@?%@", self, URL, body);
    return request;
}

#pragma mark - Persistence

- (NSString *)filePathForData:(NSString *)data
{
    NSString *filename = [NSString stringWithFormat:@"mixpanel-%@-%@.plist", self.apiToken, data];
    return [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]
            stringByAppendingPathComponent:filename];
}

- (NSString *)eventsFilePath
{
    return [self filePathForData:@"events"];
}

- (NSString *)peopleFilePath
{
    return [self filePathForData:@"people"];
}

- (NSString *)propertiesFilePath
{
    return [self filePathForData:@"properties"];
}

- (void)archive
{
    [self archiveEvents];
    [self archivePeople];
    [self archiveProperties];
}

- (void)archiveEvents
{
    NSString *filePath = [self eventsFilePath];
    NSMutableArray *eventsQueueCopy = [NSMutableArray arrayWithArray:[self.eventsQueue copy]];
    MixpanelDebug(@"%@ archiving events data to %@: %@", self, filePath, eventsQueueCopy);
    if (![NSKeyedArchiver archiveRootObject:eventsQueueCopy toFile:filePath]) {
        NSLog(@"%@ unable to archive events data", self);
    }
}

- (void)archivePeople
{
    NSString *filePath = [self peopleFilePath];
    NSMutableArray *peopleQueueCopy = [NSMutableArray arrayWithArray:[self.peopleQueue copy]];
    MixpanelDebug(@"%@ archiving people data to %@: %@", self, filePath, peopleQueueCopy);
    if (![NSKeyedArchiver archiveRootObject:peopleQueueCopy toFile:filePath]) {
        NSLog(@"%@ unable to archive people data", self);
    }
}

- (void)archiveProperties
{
    NSString *filePath = [self propertiesFilePath];
    NSMutableDictionary *p = [NSMutableDictionary dictionary];
    [p setValue:self.distinctId forKey:@"distinctId"];
    [p setValue:self.nameTag forKey:@"nameTag"];
    [p setValue:self.superProperties forKey:@"superProperties"];
    [p setValue:self.people.distinctId forKey:@"peopleDistinctId"];
    [p setValue:self.people.unidentifiedQueue forKey:@"peopleUnidentifiedQueue"];
    MixpanelDebug(@"%@ archiving properties data to %@: %@", self, filePath, p);
    if (![NSKeyedArchiver archiveRootObject:p toFile:filePath]) {
        NSLog(@"%@ unable to archive properties data", self);
    }
}

- (void)unarchive
{
    [self unarchiveEvents];
    [self unarchivePeople];
    [self unarchiveProperties];
}

- (void)unarchiveEvents
{
    NSString *filePath = [self eventsFilePath];
    @try {
        self.eventsQueue = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        MixpanelDebug(@"%@ unarchived events data: %@", self, self.eventsQueue);
    }
    @catch (NSException *exception) {
        NSLog(@"%@ unable to unarchive events data, starting fresh", self);
        self.eventsQueue = nil;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSError *error;
        BOOL removed = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        if (!removed) {
            NSLog(@"%@ unable to remove archived events file at %@ - %@", self, filePath, error);
        }
    }
    if (!self.eventsQueue) {
        self.eventsQueue = [NSMutableArray array];
    }
}

- (void)unarchivePeople
{
    NSString *filePath = [self peopleFilePath];
    @try {
        self.peopleQueue = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        MixpanelDebug(@"%@ unarchived people data: %@", self, self.peopleQueue);
    }
    @catch (NSException *exception) {
        NSLog(@"%@ unable to unarchive people data, starting fresh", self);
        self.peopleQueue = nil;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSError *error;
        BOOL removed = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        if (!removed) {
            NSLog(@"%@ unable to remove archived people file at %@ - %@", self, filePath, error);
        }
    }
    if (!self.peopleQueue) {
        self.peopleQueue = [NSMutableArray array];
    }
}

- (void)unarchiveProperties
{
    NSString *filePath = [self propertiesFilePath];
    NSDictionary *properties = nil;
    @try {
        properties = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        MixpanelDebug(@"%@ unarchived properties data: %@", self, properties);
    }
    @catch (NSException *exception) {
        NSLog(@"%@ unable to unarchive properties data, starting fresh", self);
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSError *error;
        BOOL removed = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        if (!removed) {
            NSLog(@"%@ unable to remove archived properties file at %@ - %@", self, filePath, error);
        }
    }
    if (properties) {
        self.distinctId = [properties objectForKey:@"distinctId"] ? [properties objectForKey:@"distinctId"] : [self defaultDistinctId];
        self.nameTag = [properties objectForKey:@"nameTag"];
        self.superProperties = [properties objectForKey:@"superProperties"] ? [properties objectForKey:@"superProperties"] : [NSMutableDictionary dictionary];
        self.people.distinctId = [properties objectForKey:@"peopleDistinctId"];
        self.people.unidentifiedQueue = [properties objectForKey:@"peopleUnidentifiedQueue"] ? [properties objectForKey:@"peopleUnidentifiedQueue"] : [NSMutableArray array];
    }
}

#pragma mark - UIApplication notifications

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    MixpanelDebug(@"%@ application did become active", self);
    [self startFlushTimer];

}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    MixpanelDebug(@"%@ application will resign active", self);
    [self stopFlushTimer];
    
    if (self.flushOnBackground){
        [self flush];
    }
}



- (void)applicationWillTerminate:(NSNotification *)notification
{
    MixpanelDebug(@"%@ application will terminate", self);
    dispatch_async(_serialQueue, ^{
       [self archive];
    });
}

@end

@implementation MixpanelPeople

- (id)initWithMixpanel:(Mixpanel *)mixpanel
{
    if (self = [self init]) {
        self.mixpanel = mixpanel;
        self.unidentifiedQueue = [NSMutableArray array];
        self.automaticPeopleProperties = [self collectAutomaticPeopleProperties];
    }
    return self;
}

- (NSString *)description
{
    __strong Mixpanel *strongMixpanel = _mixpanel;
    return [NSString stringWithFormat:@"<MixpanelPeople: %p %@>", self, (strongMixpanel ? strongMixpanel.apiToken : @"")];
}

- (NSDictionary *)collectAutomaticPeopleProperties
{
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    [properties setValue:[processInfo operatingSystemVersionString] forKey:@"$mac_version"];
    [properties setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"$mac_app_version"];
    __strong Mixpanel *strongMixpanel = _mixpanel;
    if (strongMixpanel) {
        [properties setValue:[strongMixpanel deviceModel] forKey:@"$mac_device_model"];
    }
    return [NSDictionary dictionaryWithDictionary:properties];
}

- (void)addPeopleRecordToQueueWithAction:(NSString *)action andProperties:(NSDictionary *)properties
{
    properties = [properties copy];
    NSNumber *epochMilliseconds = @(round([[NSDate date] timeIntervalSince1970] * 1000));
    __strong Mixpanel *strongMixpanel = _mixpanel;
    if (strongMixpanel) {
        dispatch_async(strongMixpanel.serialQueue, ^{
            NSMutableDictionary *r = [NSMutableDictionary dictionary];
            NSMutableDictionary *p = [NSMutableDictionary dictionary];
            [r setObject:strongMixpanel.apiToken forKey:@"$token"];
            if (![r objectForKey:@"$time"]) {
                // milliseconds unix timestamp
                [r setObject:epochMilliseconds forKey:@"$time"];
            }
            if ([action isEqualToString:@"$set"] || [action isEqualToString:@"$set_once"]) {
                [p addEntriesFromDictionary:self.automaticPeopleProperties];
            }
            [p addEntriesFromDictionary:properties];
            [r setObject:[NSDictionary dictionaryWithDictionary:p] forKey:action];
            if (self.distinctId) {
                [r setObject:self.distinctId forKey:@"$distinct_id"];
                MixpanelLog(@"%@ queueing people record: %@", self.mixpanel, r);
                [strongMixpanel.peopleQueue addObject:r];
                if ([strongMixpanel.peopleQueue count] > 500) {
                    [strongMixpanel.peopleQueue removeObjectAtIndex:0];
                }
            } else {
                MixpanelLog(@"%@ queueing unidentified people record: %@", self.mixpanel, r);
                [self.unidentifiedQueue addObject:r];
                if ([self.unidentifiedQueue count] > 500) {
                    [self.unidentifiedQueue removeObjectAtIndex:0];
                }
            }
            if ([Mixpanel inBackground]) {
                [strongMixpanel archivePeople];
            }
        });
    }
}

- (void)addPushDeviceToken:(NSData *)deviceToken
{
    const unsigned char *buffer = (const unsigned char *)[deviceToken bytes];
    if (!buffer) {
        return;
    }
    NSMutableString *hex = [NSMutableString stringWithCapacity:(deviceToken.length * 2)];
    for (NSUInteger i = 0; i < deviceToken.length; i++) {
        [hex appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)buffer[i]]];
    }
    NSArray *tokens = @[[NSString stringWithString:hex]];
    NSDictionary *properties = @{@"$ios_devices": tokens};
    [self addPeopleRecordToQueueWithAction:@"$union" andProperties:properties];
}

- (void)set:(NSDictionary *)properties
{
    NSAssert(properties != nil, @"properties must not be nil");
    [Mixpanel assertPropertyTypes:properties];
    [self addPeopleRecordToQueueWithAction:@"$set" andProperties:properties];
}

- (void)set:(NSString *)property to:(id)object
{
    NSAssert(property != nil, @"property must not be nil");
    NSAssert(object != nil, @"object must not be nil");
    if (property == nil || object == nil) {
        return;
    }
    [self set:@{property: object}];
}

- (void)setOnce:(NSDictionary *)properties
{
    NSAssert(properties != nil, @"properties must not be nil");
    [Mixpanel assertPropertyTypes:properties];
    [self addPeopleRecordToQueueWithAction:@"$set_once" andProperties:properties];
}

- (void)increment:(NSDictionary *)properties
{
    NSAssert(properties != nil, @"properties must not be nil");
    for (id __unused v in [properties allValues]) {
        NSAssert([v isKindOfClass:[NSNumber class]],
                 @"%@ increment property values should be NSNumber. found: %@", self, v);
    }
    [self addPeopleRecordToQueueWithAction:@"$add" andProperties:properties];
}

- (void)increment:(NSString *)property by:(NSNumber *)amount
{
    NSAssert(property != nil, @"property must not be nil");
    NSAssert(amount != nil, @"amount must not be nil");
    if (property == nil || amount == nil) {
        return;
    }
    [self increment:@{property: amount}];
}

- (void)append:(NSDictionary *)properties
{
    NSAssert(properties != nil, @"properties must not be nil");
    [Mixpanel assertPropertyTypes:properties];
    [self addPeopleRecordToQueueWithAction:@"$append" andProperties:properties];
}

- (void)union:(NSDictionary *)properties
{
    NSAssert(properties != nil, @"properties must not be nil");
    for (id __unused v in [properties allValues]) {
        NSAssert([v isKindOfClass:[NSArray class]],
                 @"%@ union property values should be NSArray. found: %@", self, v);
    }
    [self addPeopleRecordToQueueWithAction:@"$union" andProperties:properties];
}

- (void)trackCharge:(NSNumber *)amount
{
    [self trackCharge:amount withProperties:nil];
}

- (void)trackCharge:(NSNumber *)amount withProperties:(NSDictionary *)properties
{
    NSAssert(amount != nil, @"amount must not be nil");
    if (amount != nil) {
        NSMutableDictionary *txn = [NSMutableDictionary dictionaryWithObjectsAndKeys:amount, @"$amount", [NSDate date], @"$time", nil];
        if (properties) {
            [txn addEntriesFromDictionary:properties];
        }
        [self append:@{@"$transactions": txn}];
    }
}

- (void)clearCharges
{
    [self set:@{@"$transactions": @[]}];
}

- (void)deleteUser
{
    [self addPeopleRecordToQueueWithAction:@"$delete" andProperties:@{}];
}

@end
