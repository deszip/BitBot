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

typedef NS_ENUM(NSUInteger, BRAppVersion) {
    BRAppVersion_Undefined = 0,
    
    BRAppVersion_1_1_0 = 110,
    BRAppVersion_1_2_0 = 120,
    BRAppVersion_2_0_0 = 200
};

static NSString * const kBRAppVersion_1_1_0 = @"1.1.0";
static NSString * const kBRAppVersion_1_2_0 = @"1.2.0";
static NSString * const kBRAppVersion_2_0_0 = @"2.0.0";

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
- (BRAppVersion)appVersion;
- (BOOL)isFirstLaunch;

#pragma mark - Autorun -
- (BOOL)autolaunchEnabled;
- (void)toggleAutolaunch;

#pragma mark - CoreData Store -
- (BOOL)storeMigrationRequired;
- (NSURL *)storeURL;
- (NSURL *)storeURLForTVApp;
- (NSURL *)storeURLForMacOSApp;
- (NSURL *)storeURLForAppGroup;

#if TARGET_OS_OSX
#pragma mark - App control -
- (void)hidePopover;
#endif

@end

NS_ASSUME_NONNULL_END
