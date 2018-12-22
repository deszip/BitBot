//
//  BRAccountsViewController.h
//  Bitrise
//
//  Created by Deszip on 05/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "BRViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRAccountsViewController : BRViewController

@property (strong, nonatomic) id <BRDataSourceProvider, BRInteractionProvider, BREnvironmentProvider> dependencyContainer;

@end

NS_ASSUME_NONNULL_END
