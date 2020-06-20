//
//  BRNotificationDispatcher.m
//  Bitrise
//
//  Created by Deszip on 17.05.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

#import "BRNotificationDispatcher.h"

#import "BRLogger.h"
#import "NSArray+FRP.h"

static const NSTimeInterval kNotificationTTL = 15;
static NSString * const kBRNotificationsKey = @"kBRNotificationsKey";
static NSString * const kBRNotificationPrimaryActionKey = @"kBRNotificationPrimaryActionKey";
static NSString * const kBRNotificationSecondaryActionKey = @"kBRNotificationSecondaryActionKey";
static NSString * const kBRNotificationBuildInfoKey = @"kBRNotificationBuildInfoKey";

typedef NS_ENUM(NSUInteger, BRNotificationAction) {
    BRNotificationActionOpen = 0,
    BRNotificationActionAbort,
    BRNotificationActionRebuild
};

@interface BRNotificationDispatcher() <NSUserNotificationCenterDelegate>

@property (strong, nonatomic) NSUserDefaults *defaults;
@property (strong, nonatomic) NSUserNotificationCenter *nc;

@end

@implementation BRNotificationDispatcher

- (instancetype)initWithDefaults:(NSUserDefaults *)defaults nc:(NSUserNotificationCenter *)nc {
    if (self = [super init]) {
        _defaults = defaults;
        _nc = nc;
        [_nc  setDelegate:self];
    }
    
    return self;
}

#pragma mark - Notifications info -

- (BOOL)notificationsEnabled {
    return [self.defaults boolForKey:kBRNotificationsKey];
}

- (void)toggleNotifications {
    [self.defaults setBool:![self notificationsEnabled] forKey:kBRNotificationsKey];
}

#pragma mark - Notifications actions -

- (void)postNotifications:(NSArray<BRBuildInfo *> *)builds {
    if (![self notificationsEnabled] || builds.count == 0) {
        return;
    }
    
    [[builds aps_map:^NSUserNotification *(BRBuildInfo *buildInfo) {
        return [self notificationFor:buildInfo];
    }] enumerateObjectsUsingBlock:^(NSUserNotification *notification, NSUInteger idx, BOOL *stop) {
        [self.nc deliverNotification:notification];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kNotificationTTL * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self cleanupDeliveredNotifications];
        });
    }];
}

#pragma mark - Private API -

- (void)cleanupDeliveredNotifications {
    [self.nc.deliveredNotifications enumerateObjectsUsingBlock:^(NSUserNotification *notification, NSUInteger idx, BOOL *stop) {
        [self.nc removeDeliveredNotification:notification];
    }];
}

- (NSUserNotification *)notificationFor:(BRBuildInfo *)buildInfo {
    NSMutableDictionary *userInfo = [@{ kBRNotificationPrimaryActionKey : @(BRNotificationActionOpen),
                                        kBRNotificationBuildInfoKey : buildInfo } mutableCopy];
    
    NSUserNotification *notification = [NSUserNotification new];
    notification.identifier = [self notificationID:buildInfo];
    notification.title = buildInfo.appName;
    notification.actionButtonTitle = @"Open build";
    
    switch (buildInfo.stateInfo.state) {
        case BRBuildStateHold:
            notification.subtitle = @"build on hold";
            notification.otherButtonTitle = @"Abort";
            userInfo[kBRNotificationSecondaryActionKey] = @(BRNotificationActionAbort);
            break;
        case BRBuildStateInProgress:
            notification.subtitle = @"build started";
            notification.otherButtonTitle = @"Abort";
            userInfo[kBRNotificationSecondaryActionKey] = @(BRNotificationActionAbort);
            break;
        case BRBuildStateFailed:
            notification.subtitle = @"build failed";
            notification.otherButtonTitle = @"Rebuild";
            userInfo[kBRNotificationSecondaryActionKey] = @(BRNotificationActionRebuild);
            break;
        case BRBuildStateAborted:
            notification.subtitle = @"build aborted";
            notification.otherButtonTitle = @"Rebuild";
            userInfo[kBRNotificationSecondaryActionKey] = @(BRNotificationActionRebuild);
            break;
        case BRBuildStateSuccess:
            notification.subtitle = @"build finished";
            break;
            
        default:
            notification.subtitle = @"build state undefined";
            break;
    }
    
    notification.contentImage = [NSImage imageNamed:buildInfo.stateInfo.notificationImageName];
    notification.informativeText = [NSString stringWithFormat:@"Branch: %@, workflow: %@", buildInfo.branchName, buildInfo.workflowName];
    notification.soundName = NSUserNotificationDefaultSoundName;
    
    return notification;
}

- (NSString *)notificationID:(BRBuildInfo *)buildInfo {
    return [NSString stringWithFormat:@"%@-%lu", buildInfo.slug, (unsigned long)buildInfo.stateInfo.state];
}

- (BRBuildState)stateFromNotificationID:(NSString *)notificationID {
    return (BRBuildState)[[[notificationID componentsSeparatedByString:@"-"] lastObject] integerValue];
}

#pragma mark - NSUserNotificationCenterDelegate -

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    
    BRLog(LL_VERBOSE, LL_CORE, @"Notification activated: %@", notification);
    
    switch (notification.activationType) {
        case NSUserNotificationActivationTypeAdditionalActionClicked:
            BRLog(LL_VERBOSE, LL_CORE, @"Additional action clicked");
            break;
        
        case NSUserNotificationActivationTypeActionButtonClicked:
            BRLog(LL_VERBOSE, LL_CORE, @"Action clicked");
            break;
            
        case NSUserNotificationActivationTypeContentsClicked:
            BRLog(LL_VERBOSE, LL_CORE, @"Content clicked");
            break;
            
        default:
            break;
    }
}


@end
