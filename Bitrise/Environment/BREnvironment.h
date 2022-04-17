//
//  BREnvironment.h
//  BitBot
//
//  Created by Deszip on 21/12/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BRAutorun.h"

NS_ASSUME_NONNULL_BEGIN

@interface BREnvironment : NSObject

#if TARGET_OS_OSX
- (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithAutorun:(BRAutorun *)autorun NS_DESIGNATED_INITIALIZER;
#endif

- (void)handleAppLaunch:(void(^)(void))firstLaunchHandler;

#pragma mark - Info -
- (NSString *)versionNumber;
- (NSString *)buildNumber;

#pragma mark - Autorun -
- (BOOL)autolaunchEnabled;
- (void)toggleAutolaunch;

#if TARGET_OS_OSX
#pragma mark - App control -
- (void)hidePopover;
#endif

@end

NS_ASSUME_NONNULL_END
