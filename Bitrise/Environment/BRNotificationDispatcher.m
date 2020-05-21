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

static NSString * const kBRNotificationsKey = @"kBRNotificationsKey";

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
    }];
}

#pragma mark - Private API -

- (NSUserNotification *)notificationFor:(BRBuildInfo *)buildInfo {
    NSUserNotification *notification = [NSUserNotification new];
    notification.identifier = [NSString stringWithFormat:@"%@-%lu", buildInfo.slug, (unsigned long)buildInfo.stateInfo.state];
    notification.title = buildInfo.appName;
    
    switch (buildInfo.stateInfo.state) {
        case BRBuildStateHold:
            notification.subtitle = @"build on hold";
            break;
        case BRBuildStateInProgress:
            notification.subtitle = @"build started";
            break;
        case BRBuildStateFailed:
            notification.subtitle = @"build failed";
            break;
        case BRBuildStateAborted:
            notification.subtitle = @"build aborted";
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
    
    notification.actionButtonTitle = @"Action";
    notification.otherButtonTitle = @"Other";
    
    return notification;
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
