//
//  BRAnalytics.m
//  Bitrise
//
//  Created by Deszip on 04/05/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRAnalytics.h"

#import <Mixpanel/Mixpanel.h>
#import <Sentry/Sentry.h>

static NSString * const kBRAnalyticsAvailabilityKey = @"kBRAnalyticsAvailabilityKey";

static NSString * const kBRMixpanelOSXToken = @"ae64ff4c78b73e7f945f63aa02677fbb";
static NSString * const kBRMixpanelATVToken = @"4d209b738bd7dc6965ad1325080f83f1";

#if DEBUG
static NSString * const kBRSentryOSXDSNPath = @"https://16702f55ff1346e49d6ae3aa41bffc8b@o577211.ingest.sentry.io/5731739";
#else
static NSString * const kBRSentryOSXDSNPath = @"https://c955ed8ebdfc4db6bc206bfec0db2af2@o577211.ingest.sentry.io/5783183";
#endif

static NSString * const kBRSentryATVDSNPath = @"https://eb1b1d1669e344d2a0799c79ec1c78ce@o577211.ingest.sentry.io/5737938";

typedef NSString BRAnalyticsEvent;

static BRAnalyticsEvent * const kQuitAppEvent = @"app_quit";
static BRAnalyticsEvent * const kAboutScreenEvent = @"app_showabout";
static BRAnalyticsEvent * const kAccountsScreenEvent = @"app_showaccounts";
static BRAnalyticsEvent * const kAutorunToggleEvent = @"app_autoruntoggle";
static BRAnalyticsEvent * const kNotificationsToggleEvent = @"app_notificationstoggle";
static BRAnalyticsEvent * const kAnalyticsToggleEvent = @"app_analyticstoggle";

static BRAnalyticsEvent * const kAddAccountEvent = @"account_add";
static BRAnalyticsEvent * const kAddAccountFailureEvent = @"account_add_failure";
static BRAnalyticsEvent * const kRemoveAccountEvent = @"account_remove";
static BRAnalyticsEvent * const kSyncEvent = @"build_sync";

static BRAnalyticsEvent * const kRebuildActionEvent = @"action_rebuild";
static BRAnalyticsEvent * const kAbortActionEvent = @"action_abort";
static BRAnalyticsEvent * const kLoadLogsActionEvent = @"action_loadlogs";
static BRAnalyticsEvent * const kOpenBuildActionEvent = @"action_openbuild";

@interface BRAnalytics ()

@property (strong, nonatomic) NSUserDefaults *defaults;

@end

@implementation BRAnalytics

#pragma mark - Init -

- (instancetype)initWithDefaults:(NSUserDefaults *)defaults {
    if (self = [super init]) {
        _defaults = defaults;
    }
    
    return self;
}

+ (instancetype)analytics {
    static dispatch_once_t onceToken;
    static BRAnalytics *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BRAnalytics alloc] initWithDefaults:[NSUserDefaults standardUserDefaults]];
    });
    
    return sharedInstance;
}

- (void)start {
    // First launch, enable by default
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kBRAnalyticsAvailabilityKey] == nil) {
        [[BRAnalytics analytics] setEnabled:YES];
    }
    
    // Start services if enabled
    if ([self isEnabled]) {
#if TARGET_OS_OSX
        [self startMixpanel:kBRMixpanelOSXToken];
        [self startSentry:kBRSentryOSXDSNPath];
#else
        [self startMixpanel:kBRMixpanelATVToken];
        [self startSentry:kBRSentryATVDSNPath];
#endif
    }
}

- (void)stop {
    [self stopMixpanel];
    [self stopSentry];
}

- (void)toggle {
    [self setEnabled:![self isEnabled]];
    if ([self isEnabled]) {
        [self start];
    } else {
        [self stop];
    }
}

- (void)setEnabled:(BOOL)isEnabled {
    if (isEnabled == [self isEnabled]) {
        return;
    }

    [self.defaults setBool:isEnabled forKey:kBRAnalyticsAvailabilityKey];
    [self.defaults synchronize];
}

- (BOOL)isEnabled {
    return [self.defaults boolForKey:kBRAnalyticsAvailabilityKey];
}

#pragma mark - Providers -

- (void)startMixpanel:(NSString *)token {
    [Mixpanel sharedInstanceWithToken:token];
    if ([[Mixpanel sharedInstance] hasOptedOutTracking]) {
        [[Mixpanel sharedInstance] optInTracking];
    }
}

- (void)stopMixpanel {
    [[Mixpanel sharedInstance] flush];
    [[Mixpanel sharedInstance] reset];
    [[Mixpanel sharedInstance] optOutTracking];
}

- (void)startSentry:(NSString *)dsn {
    [SentrySDK startWithConfigureOptions:^(SentryOptions *options) {
        options.dsn = dsn;
        options.tracesSampleRate = @1.0;
    }];
}

- (void)stopSentry {
    [SentrySDK close];
}

#pragma mark - Events -

- (void)trackQuitApp { [self sendEvent:kQuitAppEvent properties:@{}]; }
- (void)trackAboutOpen { [self sendEvent:kAboutScreenEvent properties:@{}]; }
- (void)trackAccountsOpen { [self sendEvent:kAccountsScreenEvent properties:@{}]; }
- (void)trackAutorunToggle { [self sendEvent:kAutorunToggleEvent properties:@{}]; }
- (void)trackNotificationsToggle { [self sendEvent:kNotificationsToggleEvent properties:@{}]; }
- (void)trackAnalyticsToggle { [self sendEvent:kAnalyticsToggleEvent properties:@{}]; }

- (void)trackAccountAdd { [self sendEvent:kAddAccountEvent properties:@{}]; }
- (void)trackAccountAddFailure:(NSError *)error {
    [self sendEvent:kAddAccountFailureEvent properties:@{}];
    [self sendError:error];
}
- (void)trackAccountRemove { [self sendEvent:kRemoveAccountEvent properties:@{}]; }
- (void)trackAccountRemoveError:(NSError *)error {
    [self sendEvent:kRemoveAccountEvent properties:@{}];
    [self sendError:error];
}
- (void)trackSyncWithStarted:(NSUInteger)started
                     running:(NSUInteger)running
                    finished:(NSUInteger)finished { [self sendEvent:kSyncEvent properties:@{ @"started" : @(started),
                                                                                             @"running" : @(running),
                                                                                             @"finished" : @(finished) }]; }
- (void)trackSyncError:(NSError *)error {
    [self sendError:error];
}

- (void)trackRebuildAction { [self sendEvent:kRebuildActionEvent properties:@{}]; }
- (void)trackAbortAction { [self sendEvent:kAbortActionEvent properties:@{}]; }
- (void)trackLoadLogsAction { [self sendEvent:kLoadLogsActionEvent properties:@{}]; }
- (void)trackOpenBuildAction { [self sendEvent:kOpenBuildActionEvent properties:@{}]; }

#pragma mark - Sending events -

- (void)sendEvent:(BRAnalyticsEvent *)name properties:(NSDictionary *)properties {
    if ([self isEnabled]) {
        [[Mixpanel sharedInstance] track:name properties:properties];
    }
}

#pragma mark - Issues -

- (void)sendError:(NSError *)error {
    [SentrySDK captureError:error];
}

@end
