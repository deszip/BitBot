//
//  BRContainerBuilder.h
//  BitBot
//
//  Created by Deszip on 05/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


NS_ASSUME_NONNULL_BEGIN

@interface BRContainerBuilder : NSObject

- (NSPersistentContainer *)buildContainer;
- (NSPersistentContainer *)buildContainerOfType:(NSString *)type;

@end

NS_ASSUME_NONNULL_END
