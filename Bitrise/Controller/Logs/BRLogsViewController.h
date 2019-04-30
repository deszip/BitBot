//
//  BRLogsViewController.h
//  Bitrise
//
//  Created by Deszip on 02/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "BRViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRLogsViewController : BRViewController

@property (strong, nonatomic) id <BRDataSourceProvider, BRInteractionProvider> dependencyContainer;
@property (copy, nonatomic) NSString *buildSlug;

@end

NS_ASSUME_NONNULL_END
