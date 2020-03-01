//
//  BRLogsTextViewController.h
//  Bitrise
//
//  Created by Deszip on 18/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRLogsTextViewController : BRViewController

@property (strong, nonatomic) id <BRDataSourceProvider, BRInteractionProvider> dependencyContainer;
@property (copy, nonatomic) BRBuildInfo *buildInfo;

@end

NS_ASSUME_NONNULL_END
