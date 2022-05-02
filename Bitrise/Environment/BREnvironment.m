//
//  BREnvironment.m
//  BitBot
//
//  Created by Deszip on 21/12/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BREnvironment.h"

#if TARGET_OS_OSX
#import "AppDelegate.h"
#endif

#import "BRMacro.h"
#import "BRLogger.h"

static NSString * const kBRNotificationsKey = @"kBRNotificationsKey";
static NSString * const kBRFirstLaunchKey = @"kBRFirstLaunchKey";

@interface BREnvironment ()

@property (strong, nonatomic) BRAutorun *autorun;

@end

@implementation BREnvironment

#if TARGET_OS_OSX
- (instancetype)initWithAutorun:(BRAutorun *)autorun {
    if (self = [super init]) {
        _autorun = autorun;
    }
    
    return self;
}
#endif

- (void)handleAppLaunch:(void(^)(void))firstLaunchHandler {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kBRFirstLaunchKey]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kBRFirstLaunchKey];
        BR_SAFE_CALL(firstLaunchHandler);
    }
}

#pragma mark - Info -

- (BOOL)isFirstLaunch {
    return ![[NSUserDefaults standardUserDefaults] boolForKey:kBRFirstLaunchKey];
        
}

- (NSString *)versionNumber {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

- (NSString *)buildNumber {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

- (BRAppVersion)appVersion {
    // @TODO: Conver version number to enum option
    //...
    return BRAppVersion_2_0_0;
}

#pragma mark - Autorun -

- (BOOL)autolaunchEnabled {
    return [self.autorun launchOnLoginEnabled];
}

- (void)toggleAutolaunch {
    [self.autorun toggleAutolaunch];
}

#pragma mark - CoreData Store -

- (BOOL)storeMigrationRequired {
    return [self appVersion] >= BRAppVersion_2_0_0;
}

- (NSURL *)storeURL {
#if TARGET_OS_OSX
    if ([self appVersion] >= BRAppVersion_2_0_0) {
        return [self storeURLForAppGroup];
    }
    return [self storeURLForMacOSApp];
#else
    return [self storeURLForTVApp];
#endif
}

- (NSURL *)storeURLAt:(NSSearchPathDirectory)containerRoot {
    NSURL *appsURL = [[NSFileManager defaultManager] URLsForDirectory:containerRoot inDomains:NSUserDomainMask][0];
    NSURL *appDirectoryURL = [appsURL URLByAppendingPathComponent:@"Bitrise"];

    BOOL isDir;
    if (![[NSFileManager defaultManager] fileExistsAtPath:appDirectoryURL.path isDirectory:&isDir]) {
        NSError *error;
        BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:appDirectoryURL.path withIntermediateDirectories:YES attributes:nil error:&error];
        if (!result) {
            BRLog(LL_WARN, LL_STORAGE, @"Failed to create app directory: %@", error);
            return nil;
        }
    }

    return [appDirectoryURL URLByAppendingPathComponent:@"bitrise.sqlite"];
}

- (NSURL *)storeURLForTVApp {
    return [self storeURLAt:NSCachesDirectory];
}

- (NSURL *)storeURLForMacOSApp {
    return [self storeURLAt:NSApplicationSupportDirectory];
}

- (NSURL *)storeURLForAppGroup {
    NSURL *groupContainerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.bitbot"];
    BOOL isDir = NO;
    BOOL containerExists = [[NSFileManager defaultManager] fileExistsAtPath:groupContainerURL.path isDirectory:&isDir];
    
    if (isDir && containerExists) {
        return [groupContainerURL URLByAppendingPathComponent:@"bitrise.sqlite"];
    }
    
    return nil;
}

//- (BOOL)dropStoreAtURL:(NSURL *)storeURL error:(NSError * __autoreleasing *)error {
//    if ([[NSFileManager defaultManager] fileExistsAtPath:storeURL.path]) {
//        NSURL *shmURL = [NSURL fileURLWithPath:[[storeURL path] stringByAppendingString:@"-shm"]];
//        NSURL *walURL = [NSURL fileURLWithPath:[[storeURL path] stringByAppendingString:@"-wal"]];
//
//        return
//        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:error] &&
//        [[NSFileManager defaultManager] removeItemAtURL:shmURL error:error] &&
//        [[NSFileManager defaultManager] removeItemAtURL:walURL error:error];
//    }
//
//    return NO;
//}

#pragma mark - App control -

#if TARGET_OS_OSX
- (void)hidePopover {
    [(AppDelegate *)[NSApp delegate] hidePopover];
}
#endif

@end
