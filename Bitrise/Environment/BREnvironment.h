//
//  BREnvironment.h
//  BitBot
//
//  Created by Deszip on 21/12/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

#import "BRAutorun.h"
#import "BRAppInfo.h"
#import "BRBuildInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface BREnvironment : NSObject

- (instancetype)initWithAutorun:(BRAutorun *)autorun;

- (void)handleAppLaunch;

#pragma mark - Notifications -

- (BOOL)notificationsEnabled;
- (void)toggleNotifications;
- (void)postNotifications:(NSArray<BRBuildInfo *> *)builds forApp:(BRAppInfo *)appInfo;

#pragma mark - Autorun -

- (BOOL)autolaunchEnabled;
- (void)toggleAutolaunch;

#pragma mark - Quit -

- (void)quitApp;

@end

NS_ASSUME_NONNULL_END
