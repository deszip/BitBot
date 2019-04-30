//
//  BRAccountsViewController.h
//  BitBot
//
//  Created by Deszip on 05/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "BRViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRAccountsViewController : BRViewController

@property (strong, nonatomic) id <BRDataSourceProvider, BRInteractionProvider> dependencyContainer;

@end

NS_ASSUME_NONNULL_END
