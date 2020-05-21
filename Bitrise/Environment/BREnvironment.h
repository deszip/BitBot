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
#import "BRNotificationDispatcher.h"

NS_ASSUME_NONNULL_BEGIN

@interface BREnvironment : NSObject

- (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithAutorun:(BRAutorun *)autorun notificationsDispatcher:(BRNotificationDispatcher *)nDispatcher NS_DESIGNATED_INITIALIZER;

- (void)handleAppLaunch;

#pragma mark - Info -
- (NSString *)versionNumber;
- (NSString *)buildNumber;

#pragma mark - Notifications -

- (BOOL)notificationsEnabled;
- (void)toggleNotifications;
- (void)postNotifications:(NSArray<BRBuildInfo *> *)builds;

#pragma mark - Autorun -

- (BOOL)autolaunchEnabled;
- (void)toggleAutolaunch;

#pragma mark - Quit -

- (void)quitApp;

@end

NS_ASSUME_NONNULL_END
