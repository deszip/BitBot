//
//  BRContainerBuilder.m
//  Bitrise
//
//  Created by Deszip on 05/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BRContainerBuilder.h"

@implementation BRContainerBuilder

- (NSPersistentContainer *)buildContainer {
    NSPersistentContainer *container = [NSPersistentContainer persistentContainerWithName:@"bitrise"];
    NSPersistentStoreDescription *storeDescription = [NSPersistentStoreDescription new];
    NSURL *documentsURL = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    storeDescription.URL = [documentsURL URLByAppendingPathComponent:@"bitrise.sqlite"];
    storeDescription.type = NSSQLiteStoreType;
    storeDescription.shouldInferMappingModelAutomatically = YES;
    storeDescription.shouldMigrateStoreAutomatically = YES;
    container.persistentStoreDescriptions = @[storeDescription];
    [container loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
        //...
    }];
    
    return container;
}

@end
