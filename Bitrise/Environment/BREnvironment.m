//
//  BREnvironment.m
//  BitBot
//
//  Created by Deszip on 21/12/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BREnvironment.h"

static NSString * const kBRNotificationsKey = @"kBRNotificationsKey";
static NSString * const kBRFirstLaunchKey = @"kBRFirstLaunchKey";

@interface BREnvironment ()

@property (strong, nonatomic) BRAutorun *autorun;

@end

@implementation BREnvironment

- (instancetype)initWithAutorun:(BRAutorun *)autorun {
    if (self = [super init]) {
        _autorun = autorun;
    }
    
    return self;
}

- (void)handleAppLaunch {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kBRFirstLaunchKey]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kBRFirstLaunchKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self toggleNotifications];
    }
}

#pragma mark - Info -

- (NSString *)versionNumber {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

- (NSString *)buildNumber {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

#pragma mark - Notifications -

- (BOOL)notificationsEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kBRNotificationsKey];
}

- (void)toggleNotifications {
    [[NSUserDefaults standardUserDefaults] setBool:![self notificationsEnabled] forKey:kBRNotificationsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)postNotifications:(NSArray<BRBuildInfo *> *)builds forApp:(BRAppInfo *)appInfo {
    if (![self notificationsEnabled] || !builds.count) {
        return;
    }
    
    [builds enumerateObjectsUsingBlock:^(BRBuildInfo *buildInfo, NSUInteger idx, BOOL *stop) {
        NSUserNotification *notification = [NSUserNotification new];
        notification.identifier = [NSString stringWithFormat:@"%@-%lu", buildInfo.slug, (unsigned long)buildInfo.stateInfo.state];
        notification.title = appInfo.title;
        
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
        
        notification.contentImage = [NSImage imageNamed:buildInfo.stateInfo.statusImageName];
        notification.informativeText = [NSString stringWithFormat:@"Branch: %@, workflow: %@", buildInfo.branchName, buildInfo.workflowName];
        notification.soundName = NSUserNotificationDefaultSoundName;
        
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    }];
}

#pragma mark - Autorun -

- (BOOL)autolaunchEnabled {
    return [self.autorun launchOnLoginEnabled];
}
- (void)toggleAutolaunch {
    [self.autorun toggleAutolaunch];
}

#pragma mark - Quit -

- (void)quitApp {
    [NSApp terminate:self];
}

@end
