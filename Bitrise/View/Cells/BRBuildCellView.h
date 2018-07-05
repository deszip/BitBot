//
//  BRBuildCellView.h
//  Bitrise
//
//  Created by Deszip on 04/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRBuildCellView : NSTableRowView

@property (weak) IBOutlet NSTextField *buildNameLabel;

@end

NS_ASSUME_NONNULL_END
