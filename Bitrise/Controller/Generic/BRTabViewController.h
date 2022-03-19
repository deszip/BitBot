//
//  BRTabViewController.h
//  BitBot
//
//  Created by Deszip on 21.11.2021.
//  Copyright © 2021 Bitrise. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRTabViewController : NSTabViewController

@property (strong, nonatomic, readonly) id dependencyContainer;

@end

NS_ASSUME_NONNULL_END
