//
//  BRaboutViewController.h
//  Bitrise
//
//  Created by Deszip on 06/01/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "BRViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRAboutViewController : BRViewController

@property (strong, nonatomic) id <BREnvironmentProvider> dependencyContainer;

@end

NS_ASSUME_NONNULL_END
