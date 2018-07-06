//
//  BRContainerBuilder.h
//  Bitrise
//
//  Created by Deszip on 05/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


NS_ASSUME_NONNULL_BEGIN

@interface BRContainerBuilder : NSObject

- (NSPersistentContainer *)buildContainer;

@end

NS_ASSUME_NONNULL_END
