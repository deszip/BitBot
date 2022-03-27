//
//  BRContainerBuilder.h
//  BitBot
//
//  Created by Deszip on 05/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "BREnvironment.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRContainerBuilder : NSObject

- (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithEnv:(BREnvironment *)environment NS_DESIGNATED_INITIALIZER;

- (NSPersistentContainer *)buildContainer;
- (NSPersistentContainer *)buildContainerOfType:(NSString *)type;

@end

NS_ASSUME_NONNULL_END
