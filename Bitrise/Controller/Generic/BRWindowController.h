//
//  BRWindowController.h
//  BitBot
//
//  Created by Deszip on 10.10.2021.
//  Copyright © 2021 Bitrise. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "BRDependencyContainer.h"

NS_ASSUME_NONNULL_BEGIN

@protocol BRDependencyContainerOwner <NSObject>

@property (strong, nonatomic) id dependencyContainer;

@end

@interface BRWindowController : NSWindowController <BRDependencyContainerOwner>

//@property (strong, nonatomic) id dependencyContainer;

- (void)didSetContainer;

@end

NS_ASSUME_NONNULL_END
