//
//  BRLogsWindowController.h
//  Bitrise
//
//  Created by Deszip on 28/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "BRLogStatusView.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRLogsWindowController : NSWindowController

@property (weak, nonatomic) IBOutlet BRLogStatusView *statusView;

@end

NS_ASSUME_NONNULL_END
