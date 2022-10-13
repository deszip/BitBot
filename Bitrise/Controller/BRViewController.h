//
//  BRViewController.h
//  BitBot
//
//  Created by Deszip on 06/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "BRDependencyContainer.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRViewController : NSViewController

@property (strong, nonatomic) id dependencyContainer;

@end

NS_ASSUME_NONNULL_END
