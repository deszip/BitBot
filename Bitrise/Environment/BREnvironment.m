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
@property (strong, nonatomic) BRNotificationDispatcher *notificationDispatcher;

@end

@implementation BREnvironment

- (instancetype)initWithAutorun:(BRAutorun *)autorun notificationsDispatcher:(BRNotificationDispatcher *)nDispatcher {
    if (self = [super init]) {
        _autorun = autorun;
        _notificationDispatcher = nDispatcher;
    }
    
    return self;
}

- (void)handleAppLaunch {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kBRFirstLaunchKey]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kBRFirstLaunchKey];
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
    return [self.notificationDispatcher notificationsEnabled];
}

- (void)toggleNotifications {
    [self.notificationDispatcher toggleNotifications];
}

- (void)postNotifications:(NSArray<BRBuildInfo *> *)builds {
    [self.notificationDispatcher postNotifications:builds];
}

#pragma mark - Autorun -

- (BOOL)autolaunchEnabled {
    return [self.autorun launchOnLoginEnabled];
}
- (void)toggleAutolaunch {
    [self.autorun toggleAutolaunch];
}

@end
