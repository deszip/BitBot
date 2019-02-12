//
//  BRLogLineView.h
//  Bitrise
//
//  Created by Deszip on 12/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRLogLineView : NSTableRowView

@property (weak) IBOutlet NSTextField *lineLabel;

@end

NS_ASSUME_NONNULL_END
