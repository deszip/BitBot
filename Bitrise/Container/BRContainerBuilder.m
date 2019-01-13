//
//  BRContainerBuilder.m
//  BitBot
//
//  Created by Deszip on 05/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRContainerBuilder.h"

@implementation BRContainerBuilder

- (NSPersistentContainer *)buildContainer {
    return [self buildContainerOfType:NSSQLiteStoreType];
}

- (NSPersistentContainer *)buildContainerOfType:(NSString *)type {
    NSPersistentContainer *container = [NSPersistentContainer persistentContainerWithName:@"bitrise"];
    NSPersistentStoreDescription *storeDescription = [NSPersistentStoreDescription new];
    NSURL *documentsURL = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    NSURL *appDirectoryURL = [documentsURL URLByAppendingPathComponent:@"/Bitrise"];
    
    BOOL isDir;
    if (![[NSFileManager defaultManager] fileExistsAtPath:appDirectoryURL.path isDirectory:&isDir]) {
        NSError *error;
        BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:appDirectoryURL.path withIntermediateDirectories:NO attributes:nil error:&error];
        if (!result) {
            NSLog(@"Failed to create app directory: %@", error);
            return nil;
        }
    }
    
    storeDescription.URL = [appDirectoryURL URLByAppendingPathComponent:@"bitrise.sqlite"];
    storeDescription.type = type;
    storeDescription.shouldInferMappingModelAutomatically = YES;
    storeDescription.shouldMigrateStoreAutomatically = YES;
    container.persistentStoreDescriptions = @[storeDescription];
    [container loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
        if (!storeDescription) {
            NSLog(@"Failed to load store: %@", error);
        }
    }];
    
    return container;
}

@end
