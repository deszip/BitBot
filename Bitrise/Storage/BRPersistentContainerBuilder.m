//
//  BRPersistentContainerBuilder.m
//  BitBot
//
//  Created by Deszip on 05/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRPersistentContainerBuilder.h"

#import "BRLogger.h"
#import "BREnvironment.h"

@interface BRPersistentContainerBuilder ()

@property (strong, nonatomic) BREnvironment *environment;

@end

@implementation BRPersistentContainerBuilder

- (instancetype)initWithEnv:(BREnvironment *)environment {
    if (self = [super init]) {
        _environment = environment;
        
        if ([_environment storeMigrationRequired]) {
            [self migrateStoreToAppGroupContainer];
        }
    }
    
    return self;
}

#pragma mark - Builder API -

- (NSPersistentContainer *)buildContainer {
    return [self buildContainerOfType:NSSQLiteStoreType atURL:[self.environment storeURL]];
}

- (NSPersistentContainer *)buildContainerOfType:(NSString *)type {
    return [self buildContainerOfType:type atURL:[self.environment storeURL]];
}

- (NSPersistentContainer *)buildContainerOfType:(NSString *)type atURL:(NSURL *)storeURL {
    NSPersistentStoreDescription *storeDescription = [NSPersistentStoreDescription new];

#if TARGET_OS_OSX
    NSPersistentContainer *container = [NSPersistentContainer persistentContainerWithName:@"bitrise"];
#else
    NSPersistentCloudKitContainer *container = [NSPersistentCloudKitContainer persistentContainerWithName:@"bitrise"];
    storeDescription.cloudKitContainerOptions = [[NSPersistentCloudKitContainerOptions alloc] initWithContainerIdentifier:@"iCloud.com.bitbot"];
    storeDescription.cloudKitContainerOptions.databaseScope = CKDatabaseScopePrivate;
    [storeDescription setOption:@YES forKey:NSPersistentStoreRemoteChangeNotificationPostOptionKey];
#endif
    storeDescription.URL = storeURL;
    storeDescription.type = type;
    storeDescription.shouldInferMappingModelAutomatically = YES;
    storeDescription.shouldMigrateStoreAutomatically = YES;
    container.persistentStoreDescriptions = @[storeDescription];
    [container loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
        if (!storeDescription) {
            BRLog(LL_WARN, LL_STORAGE, @"Failed to load store: %@", error);
        }
    }];
    
    BRLog(LL_VERBOSE, LL_STORAGE, @"Built store at: %@", storeURL);
    
    return container;
}

#pragma mark - Migration API -

- (void)forceMigrateStoreToAppGroupContainer {
    // If source store does not exist - skip
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.environment storeURLForMacOSApp].path]) {
        BRLog(LL_ERROR, LL_STORAGE, @"Migration source store does not exists, skipping...");
        return;
    }
    
    NSURL *destinationStoreURL = [self.environment storeURLForAppGroup];
    NSError *dropError;
    if (![self dropStoreAtURL:destinationStoreURL error:&dropError]) {
        BRLog(LL_ERROR, LL_STORAGE, @"Failed to drop store before force migration at %@: %@...", destinationStoreURL, dropError);
    }
    
    [self migrateStoreToAppGroupContainer];
}

- (void)migrateStoreToAppGroupContainer {
    [self migrateStoreAt:[self.environment storeURLForMacOSApp] to:[self.environment storeURLForAppGroup]];
}

#pragma mark - Migration utilities -

- (void)migrateStoreAt:(NSURL *)sourceStoreURL to:(NSURL *)destinationStoreURL {
    BRLog(LL_VERBOSE, LL_STORAGE, @"Attempting to migrate store:\nSource:\t%@\nDestination:\t%@", sourceStoreURL, destinationStoreURL);
    // If source store does not exist - skip
    if (![[NSFileManager defaultManager] fileExistsAtPath:sourceStoreURL.path]) {
        BRLog(LL_ERROR, LL_STORAGE, @"Migration source store does not exists, skipping...");
        return;
    }
    
    // If destination store exists - skip
    if ([[NSFileManager defaultManager] fileExistsAtPath:destinationStoreURL.path]) {
        BRLog(LL_ERROR, LL_STORAGE, @"Migration destination store exists, skipping...");
        return;
    }
    
    NSPersistentStore *sourceStore = nil;
    NSPersistentStore *destinationStore = nil;
    NSPersistentContainer *container = [self buildContainerOfType:NSSQLiteStoreType atURL:sourceStoreURL];
    NSPersistentStoreCoordinator *coordinator = [container persistentStoreCoordinator];
    
    NSError *error;
    sourceStore = [coordinator persistentStoreForURL:sourceStoreURL];
    if (sourceStore != nil) {
        destinationStore = [coordinator migratePersistentStore:sourceStore toURL:destinationStoreURL options:nil withType:NSSQLiteStoreType error:&error];
        if (destinationStore == nil) {
            BRLog(LL_ERROR, LL_STORAGE, @"Failed to migrate store: %@", error);
        } else {
            // You can now remove the old data at oldStoreURL
            // Note that you should do this using the NSFileCoordinator/NSFilePresenter APIs, and you should remove the other files
            // described in QA1809 as well.
            NSError *dropError;
            if (![self dropStoreAtURL:sourceStoreURL error:&dropError]) {
                BRLog(LL_ERROR, LL_STORAGE, @"Failed to drop store after migration at %@: %@...", sourceStoreURL, dropError);
            }
        }
    } else {
        BRLog(LL_ERROR, LL_STORAGE, @"Failed to init source store during migration");
    }
}

#pragma mark - Utilities -

//- (NSURL *)storeURL {
//#if TARGET_OS_OSX
////    return [self storeURLForAppGroup];
//    return [self storeURLForMacOSApp];
//#else
//    return [self storeURLForTVApp];
//#endif
//}
//
//- (NSURL *)storeURLAt:(NSSearchPathDirectory)containerRoot {
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
//}
//
//- (NSURL *)storeURLForTVApp {
//    return [self storeURLAt:NSCachesDirectory];
//}
//
//- (NSURL *)storeURLForMacOSApp {
//    return [self storeURLAt:NSApplicationSupportDirectory];
//}
//
//- (NSURL *)storeURLForAppGroup {
//    NSURL *groupContainerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.bitbot"];
//    BOOL isDir = NO;
//    BOOL containerExists = [[NSFileManager defaultManager] fileExistsAtPath:groupContainerURL.path isDirectory:&isDir];
//
//    if (isDir && containerExists) {
//        return [groupContainerURL URLByAppendingPathComponent:@"bitrise.sqlite"];
//    }
//
//    return nil;
//}
//

- (BOOL)dropStoreAtURL:(NSURL *)storeURL error:(NSError * __autoreleasing *)error {
    if ([[NSFileManager defaultManager] fileExistsAtPath:storeURL.path]) {
        NSURL *shmURL = [NSURL fileURLWithPath:[[storeURL path] stringByAppendingString:@"-shm"]];
        NSURL *walURL = [NSURL fileURLWithPath:[[storeURL path] stringByAppendingString:@"-wal"]];

        return
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:error] &&
        [[NSFileManager defaultManager] removeItemAtURL:shmURL error:error] &&
        [[NSFileManager defaultManager] removeItemAtURL:walURL error:error];
    }

    return NO;
}

@end
