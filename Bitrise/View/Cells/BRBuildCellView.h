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

@property (weak) IBOutlet NSImageView *statusImage;
@property (weak) IBOutlet NSTextField *statusLabel;
@property (weak) IBOutlet NSTextField *branchLabel;
@property (weak) IBOutlet NSTextField *workflowLabel;
@property (weak) IBOutlet NSTextField *triggerTimeLabel;
@property (weak) IBOutlet NSTextField *buildTimeLabel;
@property (weak) IBOutlet NSTextField *buildNumberLabel;

@property (weak) IBOutlet NSButton *actionButton;

- (void)setRunningSince:(NSDate *)startDate;
- (void)setFinishedAt:(NSDate *)finishDate started:(NSDate *)startDate;

@end

NS_ASSUME_NONNULL_END
