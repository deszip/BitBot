//
//  BRContainerBuilder.m
//  BitBot
//
//  Created by Deszip on 05/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRContainerBuilder.h"

#import "BRLogger.h"
#import "BREnvironment.h"

@interface BRContainerBuilder ()

@property (strong, nonatomic) BREnvironment *environment;

@end

@implementation BRContainerBuilder

- (instancetype)initWithEnv:(BREnvironment *)environment {
    if (self = [super init]) {
        _environment = environment;
    }
    
    return self;
}

- (NSPersistentContainer *)buildContainer {
    return [self buildContainerOfType:NSSQLiteStoreType];
}

- (NSPersistentContainer *)buildContainerOfType:(NSString *)type {
    NSPersistentStoreDescription *storeDescription = [NSPersistentStoreDescription new];

#if TARGET_OS_OSX
    NSSearchPathDirectory directory = NSApplicationSupportDirectory;
    NSPersistentContainer *container = [NSPersistentContainer persistentContainerWithName:@"bitrise"];
#else
    NSPersistentCloudKitContainer *container = [NSPersistentCloudKitContainer persistentContainerWithName:@"bitrise"];
    storeDescription.cloudKitContainerOptions = [[NSPersistentCloudKitContainerOptions alloc] initWithContainerIdentifier:@"iCloud.com.bitbot"];
    storeDescription.cloudKitContainerOptions.databaseScope = CKDatabaseScopePrivate;
    [storeDescription setOption:@YES forKey:NSPersistentStoreRemoteChangeNotificationPostOptionKey];
    NSSearchPathDirectory directory = NSCachesDirectory;
#endif
    
//    NSURL *appsURL = [[NSFileManager defaultManager] URLsForDirectory:directory inDomains:NSUserDomainMask][0];
//    NSURL *appDirectoryURL = [appsURL URLByAppendingPathComponent:@"Bitrise"];
//
//    BOOL isDir;
//    if (![[NSFileManager defaultManager] fileExistsAtPath:appDirectoryURL.path isDirectory:&isDir]) {
//        NSError *error;
//        BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:appDirectoryURL.path withIntermediateDirectories:YES attributes:nil error:&error];
//        if (!result) {
//            BRLog(LL_WARN, LL_STORAGE, @"Failed to create app directory: %@", error);
//            return nil;
//        }
//    }
//
//    storeDescription.URL = [appDirectoryURL URLByAppendingPathComponent:@"bitrise.sqlite"];
    
    storeDescription.URL = [self storeURLAt:directory];
    storeDescription.type = type;
    storeDescription.shouldInferMappingModelAutomatically = YES;
    storeDescription.shouldMigrateStoreAutomatically = YES;
    container.persistentStoreDescriptions = @[storeDescription];
    [container loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
        if (!storeDescription) {
            BRLog(LL_WARN, LL_STORAGE, @"Failed to load store: %@", error);
        }
    }];
    
    return container;
}

- (NSURL *)storeURLAt:(NSSearchPathDirectory)containerRoot {
//    NSURL *appsURL = [[NSFileManager defaultManager] URLsForDirectory:containerRoot inDomains:NSUserDomainMask][0];
//    NSURL *appDirectoryURL = [appsURL URLByAppendingPathComponent:@"Bitrise"];
//
//    BOOL isDir;
//    if (![[NSFileManager defaultManager] fileExistsAtPath:appDirectoryURL.path isDirectory:&isDir]) {
//        NSError *error;
//        BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:appDirectoryURL.path withIntermediateDirectories:YES attributes:nil error:&error];
//        if (!result) {
//            BRLog(LL_WARN, LL_STORAGE, @"Failed to create app directory: %@", error);
//            return nil;
//        }
//    }
//
//    return [appDirectoryURL URLByAppendingPathComponent:@"bitrise.sqlite"];
    
    NSURL *groupContainerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.bitbot"];
    BOOL isDir = NO;
    BOOL containerExists = [[NSFileManager defaultManager] fileExistsAtPath:groupContainerURL.path isDirectory:&isDir];
    //BOOL containerWriteable = [[NSFileManager defaultManager] isWritableFileAtPath:[groupContainerURL.path stringByAppendingString:@"/"]];
    
    if (isDir && containerExists) {
        return [groupContainerURL URLByAppendingPathComponent:@"bitrise.sqlite"];
    }
    
    return nil;
}

@end
