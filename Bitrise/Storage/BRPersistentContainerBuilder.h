//
//  BRPersistentContainerBuilder.h
//  BitBot
//
//  Created by Deszip on 05/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "BREnvironment.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRPersistentContainerBuilder : NSObject

- (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithEnv:(BREnvironment *)environment NS_DESIGNATED_INITIALIZER;

#pragma mark - Builder API
- (NSPersistentContainer *)buildContainer;
- (NSPersistentContainer *)buildContainerOfType:(NSString *)type;
- (NSPersistentContainer *)buildContainerOfType:(NSString *)type atURL:(NSURL *)storeURL;

#pragma mark - Migration API
- (void)migrateStoreToAppGroupContainer;

@end

NS_ASSUME_NONNULL_END
