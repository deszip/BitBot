//
//  BRKeyInputViewController.h
//  Bitrise
//
//  Created by Deszip on 31/12/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRKeyInputViewController : NSViewController

@property (copy, nonatomic) void (^inputCallback)(NSString *input);

@end

NS_ASSUME_NONNULL_END
