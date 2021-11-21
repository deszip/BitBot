//
//  BRAccountInfoViewController.h
//  BitBot
//
//  Created by Deszip on 21.11.2021.
//  Copyright © 2021 Bitrise. All rights reserved.
//

#import "BRViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRAccountInfoViewController : BRViewController

@property (strong, nonatomic) id <BREnvironmentProvider, BRDataSourceProvider> dependencyContainer;

@end

NS_ASSUME_NONNULL_END
