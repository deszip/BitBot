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

@interface BRWindowController : NSWindowController

@property (strong, nonatomic, readonly) id dependencyContainer;

@end

NS_ASSUME_NONNULL_END
