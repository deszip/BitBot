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
        
        // Should be determined by env...
        //[self migrateStoreToAppGroupContainer];
        //[self forceMigrateStoreToAppGroupContainer];
    }
    
    return self;
}

#pragma mark - Builder API -

- (NSPersistentContainer *)buildContainer {
    //return [self buildContainerOfType:NSSQLiteStoreType atURL:[self storeURL]];
    return [self buildContainerOfType:NSSQLiteStoreType atURL:[self storeURLForAppGroup]];
}

- (NSPersistentContainer *)buildContainerOfType:(NSString *)type {
    return [self buildContainerOfType:type atURL:[self storeURL]];
}

- (NSPersistentContainer *)buildContainerOfType:(NSString *)type atURL:(NSURL *)storeURL {
    NSPersistentStoreDescription *storeDescription = [NSPersistentStoreDescription new];

#if TARGET_OS_OSX
//    NSSearchPathDirectory directory = NSApplicationSupportDirectory;
    NSPersistentContainer *container = [NSPersistentContainer persistentContainerWithName:@"bitrise"];
#else
    NSPersistentCloudKitContainer *container = [NSPersistentCloudKitContainer persistentContainerWithName:@"bitrise"];
    storeDescription.cloudKitContainerOptions = [[NSPersistentCloudKitContainerOptions alloc] initWithContainerIdentifier:@"iCloud.com.bitbot"];
    storeDescription.cloudKitContainerOptions.databaseScope = CKDatabaseScopePrivate;
    [storeDescription setOption:@YES forKey:NSPersistentStoreRemoteChangeNotificationPostOptionKey];
//    NSSearchPathDirectory directory = NSCachesDirectory;
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
    
    //storeDescription.URL = [self storeURLAt:directory];
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
    
    return container;
}

#pragma mark - Migration API -

- (void)forceMigrateStoreToAppGroupContainer {
    NSURL *destinationStoreURL = [self storeURLForAppGroup];
    if ([[NSFileManager defaultManager] fileExistsAtPath:destinationStoreURL.path]) {
        NSError *error;
        if (![[NSFileManager defaultManager] removeItemAtURL:destinationStoreURL error:&error]) {
            BRLog(LL_ERROR, LL_STORAGE, @"Failed to remove migration destination store: %@", error);
            return;
        }
    }
    
    [self migrateStoreAt:[self storeURLAt:NSApplicationSupportDirectory] to:destinationStoreURL];
}

- (void)migrateStoreToAppGroupContainer {
    [self migrateStoreAt:[self storeURLAt:NSApplicationSupportDirectory] to:[self storeURLForAppGroup]];
}

#pragma mark - Migration utilities -

- (void)migrateStoreAt:(NSURL *)sourceStoreURL to:(NSURL *)destinationStoreURL {
    BRLog(LL_VERBOSE, LL_STORAGE, @"Attempting to migrate store:\nSource:\t%@\nDestination:\t%@", sourceStoreURL, destinationStoreURL);
    
    NSPersistentStore   *sourceStore        = nil;
    NSPersistentStore   *destinationStore   = nil;
    NSDictionary        *storeOptions       = @{ NSSQLitePragmasOption : @{ @"journal_mode" : @"WAL" } };

    NSPersistentContainer *container = [self buildContainerOfType:NSSQLiteStoreType atURL:[self storeURLAt:NSApplicationSupportDirectory]];
    NSPersistentStoreCoordinator *coordinator = [container persistentStoreCoordinator];
    
    // If destination store exists - skip
    if ([[NSFileManager defaultManager] fileExistsAtPath:destinationStoreURL.path]) {
        BRLog(LL_ERROR, LL_STORAGE, @"Migration destination store exists, skipping...");
        return;
    }
    
    NSError *error;
//    if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:sourceStoreURL options:storeOptions error:&error]){
//        BRLog(LL_ERROR, LL_STORAGE, @"Failed to add source store during migration: %@", error);
//    } else {
        sourceStore = [coordinator persistentStoreForURL:sourceStoreURL];
        if (sourceStore != nil) {
            destinationStore = [coordinator migratePersistentStore:sourceStore toURL:destinationStoreURL options:storeOptions withType:NSSQLiteStoreType error:&error];
            if (destinationStore == nil) {
                BRLog(LL_ERROR, LL_STORAGE, @"Failed to migrate store: %@", error);
            } else {
                // You can now remove the old data at oldStoreURL
                // Note that you should do this using the NSFileCoordinator/NSFilePresenter APIs, and you should remove the other files
                // described in QA1809 as well.
                //...
            }
        } else {
            BRLog(LL_ERROR, LL_STORAGE, @"Failed to init source store during migration");
        }
//    }
}

#pragma mark - Utilities -

- (NSURL *)storeURL {
#if TARGET_OS_OSX
    return [self storeURLForAppGroup];
//    return [self storeURLAt:NSApplicationSupportDirectory];
#else
    return [self storeURLAt:NSCachesDirectory];
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
    
//    NSURL *groupContainerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.bitbot"];
//    BOOL isDir = NO;
//    BOOL containerExists = [[NSFileManager defaultManager] fileExistsAtPath:groupContainerURL.path isDirectory:&isDir];
//    //BOOL containerWriteable = [[NSFileManager defaultManager] isWritableFileAtPath:[groupContainerURL.path stringByAppendingString:@"/"]];
//
//    if (isDir && containerExists) {
//        return [groupContainerURL URLByAppendingPathComponent:@"bitrise.sqlite"];
//    }
//
//    return nil;
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

@end
