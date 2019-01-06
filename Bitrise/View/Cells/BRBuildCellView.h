//
//  BRBuildCellView.h
//  BitBot
//
//  Created by Deszip on 04/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRBuildCellView : NSTableRowView

@property (weak) IBOutlet NSImageView *statusImage;
@property (weak) IBOutlet NSImageView *backgroundStatusImage;
@property (weak) IBOutlet NSView *statusImageContainer;

@property (weak) IBOutlet NSTextField *statusLabel;
@property (weak) IBOutlet NSTextField *appTitleLabel;
@property (weak) IBOutlet NSTextField *branchLabel;
@property (weak) IBOutlet NSTextField *workflowLabel;
@property (weak) IBOutlet NSTextField *triggerTimeLabel;
@property (weak) IBOutlet NSTextField *buildTimeLabel;
@property (weak) IBOutlet NSTextField *buildNumberLabel;

- (void)spinImage:(BOOL)spin;
- (void)setRunningSince:(NSDate *)startDate;
- (void)setFinishedAt:(NSDate *)finishDate started:(NSDate *)startDate;

@end

NS_ASSUME_NONNULL_END
