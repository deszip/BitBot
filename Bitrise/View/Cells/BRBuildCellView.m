//
//  BRBuildCellView.m
//  BitBot
//
//  Created by Deszip on 04/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "BRBuildCellView.h"
#import "BRStyleSheet.h"

#define SHOWS_MENU_BUTTON 0

@interface BRBuildCellView ()

@property (strong, nonatomic) NSTrackingArea *trackingArea;

@property (weak) IBOutlet NSView *backgroundView;
@property (strong, nonatomic) NSDateFormatter *durationFormatter;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation BRBuildCellView

- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        _durationFormatter = [NSDateFormatter new];
        [_durationFormatter setDateFormat:@"m'm' s's'"];
        
        [self setContainerColor:[NSColor clearColor]];
        
#if SHOWS_MENU_BUTTON
        NSTrackingAreaOptions options = (NSTrackingMouseEnteredAndExited |
                                         NSTrackingActiveInKeyWindow |
                                         NSTrackingInVisibleRect |
                                         NSTrackingEnabledDuringMouseDrag);
        NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:self.frame options:options owner:self userInfo:nil];
        [self addTrackingArea:trackingArea];
#endif
        
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [self.layer setBackgroundColor:[BRStyleSheet backgroundColor].CGColor];
    [self.layer setMasksToBounds:YES];
    
    [self.statusImageContainer.layer setMasksToBounds:YES];
    [self.statusImageContainer.layer setCornerRadius:[BRStyleSheet buildIconCorenerRadius]];
    [self.statusImageContainer setWantsLayer:YES];
    [self.statusImageContainer setLayerContentsRedrawPolicy:NSViewLayerContentsRedrawOnSetNeedsDisplay];
    
    [self.accountLabel setTextColor:[BRStyleSheet secondaryTextColor]];
    [self.appTitleLabel setTextColor:[BRStyleSheet primaryTextColor]];
    [self.branchLabel setTextColor:[BRStyleSheet secondaryTextColor]];
    [self.commitLabel setTextColor:[BRStyleSheet secondaryTextColor]];
    [self.workflowLabel setTextColor:[BRStyleSheet secondaryTextColor]];
    [self.triggerTimeLabel setTextColor:[BRStyleSheet secondaryTextColor]];
    [self.buildTimeLabel setTextColor:[BRStyleSheet secondaryTextColor]];
    [self.buildNumberLabel setTextColor:[BRStyleSheet secondaryTextColor]];
    
    /// Fonts
    [self.accountLabel setFont:[BRStyleSheet accountNameFont]];
    [self.appTitleLabel setFont:[BRStyleSheet appNameFont]];
    [self.branchLabel setFont:[BRStyleSheet buildDetailsFont]];
    [self.commitLabel setFont:[BRStyleSheet buildDetailsFont]];
    [self.workflowLabel setFont:[BRStyleSheet buildDetailsFont]];
    [self.triggerTimeLabel setFont:[BRStyleSheet buildDetailsFont]];
    [self.buildTimeLabel setFont:[BRStyleSheet buildDetailsFont]];
    [self.buildNumberLabel setFont:[BRStyleSheet buildDetailsFont]];
    
    [self.menuButton setHidden:YES];
}

- (void)mouseEntered:(NSEvent *)event {
    [self.menuButton setHidden:NO];
}

- (void)mouseExited:(NSEvent *)event {
    [self.menuButton setHidden:YES];
}

#pragma mark - Accessors -

- (void)setContainerColor:(NSColor *)color {
    [self.statusImageContainer setWantsLayer:YES];
    [self.statusImageContainer.layer setBackgroundColor:color.CGColor];
}

#pragma mark - Animations -

- (void)spinImage:(BOOL)spin {
    if (spin) {
        // Assign layers
        CALayer *layer = [self.statusImage makeBackingLayer];
        [self.statusImage setLayer:layer];
        
        // Customize layer
        CGPoint center = CGPointMake(layer.superlayer.bounds.size.width / 2, layer.superlayer.bounds.size.height / 2);
        layer.position = center;
        layer.anchorPoint = CGPointMake(0.5, 0.5);
        [layer setCornerRadius:self.statusImage.bounds.size.width / 2];
        
        // Build animation
        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat: -M_PI * 2.0 * [BRStyleSheet buildIconSpinDurationSec]];
        rotationAnimation.duration = [BRStyleSheet buildIconSpinDurationSec];
        rotationAnimation.cumulative = YES;
        rotationAnimation.repeatCount = HUGE_VALF;
        [layer addAnimation:rotationAnimation forKey:@"transform"];
    } else {
        [self.statusImage.layer setCornerRadius:0];
        [self.statusImage.layer removeAllAnimations];
    }
}

#pragma mark - Build timer -

- (void)setRunningSince:(NSDate *)startDate {
    void (^buildDurationUpdate)(NSTimer *) = ^void(NSTimer *timer) {
        NSTimeInterval duration = (startDate == nil) ? 0 : [[NSDate date] timeIntervalSinceDate:startDate];
        [self updateBuildTime:duration];
    };
    buildDurationUpdate(self.timer);
    
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:buildDurationUpdate];

}

- (void)setFinishedAt:(NSDate *)finishDate started:(NSDate *)startDate {
    [self.timer invalidate];
    
    NSTimeInterval duration = [finishDate timeIntervalSinceDate:startDate];
    [self updateBuildTime:duration];
}

#pragma mark - Time calculations -

- (void)updateBuildTime:(NSTimeInterval)buildDuration {
    NSDate *buildDurationDate = [NSDate dateWithTimeIntervalSince1970:buildDuration];
    [self.buildTimeLabel setStringValue:[NSString stringWithFormat:@"%@", [self.durationFormatter stringFromDate:buildDurationDate]]];
}

@end
