//
//  BREnvironment.h
//  BitBot
//
//  Created by Deszip on 21/12/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BRAutorun.h"

#if TARGET_OS_OSX
#import "BRNotificationDispatcher.h"
#endif

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kBRUserIdentityKey;

@interface BREnvironment : NSObject

- (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

#if TARGET_OS_OSX
- (instancetype)initWithAutorun:(BRAutorun *)autorun notificationsDispatcher:(BRNotificationDispatcher *)nDispatcher NS_DESIGNATED_INITIALIZER;
#endif

- (void)handleAppLaunch;

#pragma mark - Info -
- (NSString *)versionNumber;
- (NSString *)buildNumber;
- (NSString *)userIdentity;

#pragma mark - Notifications -

- (BOOL)notificationsEnabled;
- (void)toggleNotifications;
- (void)postNotifications:(NSArray<BRBuildInfo *> *)builds;

#pragma mark - Autorun -

- (BOOL)autolaunchEnabled;
- (void)toggleAutolaunch;

#pragma mark - App control -

- (void)hidePopover;
- (void)quitApp;

@end

NS_ASSUME_NONNULL_END
