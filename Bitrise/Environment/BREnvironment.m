//
//  BREnvironment.m
//  BitBot
//
//  Created by Deszip on 21/12/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BREnvironment.h"

#import "AppDelegate.h"
#import "BRMacro.h"

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

- (void)handleAppLaunch:(void(^)(void))firstLaunchHandler {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kBRFirstLaunchKey]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kBRFirstLaunchKey];
        BR_SAFE_CALL(firstLaunchHandler);
    }
}

#pragma mark - Info -

- (NSString *)versionNumber {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

- (NSString *)buildNumber {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

#pragma mark - Autorun -

- (BOOL)autolaunchEnabled {
    return [self.autorun launchOnLoginEnabled];
}

- (void)toggleAutolaunch {
    [self.autorun toggleAutolaunch];
}

#pragma mark - App control -

- (void)hidePopover {
    [(AppDelegate *)[NSApp delegate] hidePopover];
}

- (void)quitApp {
    [NSApp terminate:self];
}

@end
