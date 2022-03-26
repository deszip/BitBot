//
//  BRSettingsViewController.h
//  BitBot
//
//  Created by Deszip on 19.03.2022.
//  Copyright © 2022 Bitrise. All rights reserved.
//

#import "BRViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRSettingsViewController : BRViewController

@property (strong, nonatomic, readonly) id <BREnvironmentProvider, BRDataSourceProvider> dependencyContainer;

@end

NS_ASSUME_NONNULL_END
