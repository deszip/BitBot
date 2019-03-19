//
//  BRLogStepView.h
//  Bitrise
//
//  Created by Deszip on 16/03/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRLogStepView : NSTableRowView

@property (weak) IBOutlet NSTextField *stepLabel;

@end

NS_ASSUME_NONNULL_END
