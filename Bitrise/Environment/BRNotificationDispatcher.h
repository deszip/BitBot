//
//  BRNotificationDispatcher.h
//  Bitrise
//
//  Created by Deszip on 17.05.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BRAppInfo.h"
#import "BRBuildInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRNotificationDispatcher : NSObject

#if TARGET_OS_OSX
- (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithDefaults:(NSUserDefaults *)defaults
                              nc:(NSUserNotificationCenter *)nc NS_DESIGNATED_INITIALIZER;
#endif

#pragma mark - Notifications info -
- (BOOL)notificationsEnabled;
- (void)toggleNotifications;

#pragma mark - Notifications actions -
- (void)postNotifications:(NSArray<BRBuildInfo *> *)builds;

@end

NS_ASSUME_NONNULL_END
