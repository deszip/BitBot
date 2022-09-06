//
//  BRStatsViewController.h
//  BitBot
//
//  Created by Deszip on 24.08.2022.
//  Copyright © 2022 Bitrise. All rights reserved.
//

#import "BRViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRStatsViewController : BRViewController

@property (strong, nonatomic, readonly) id <BREnvironmentProvider, BRDataSourceProvider> dependencyContainer;

@end

NS_ASSUME_NONNULL_END
