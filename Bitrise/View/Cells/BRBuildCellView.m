//
//  BRBuildCellView.m
//  Bitrise
//
//  Created by Deszip on 04/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "BRBuildCellView.h"

static const NSTimeInterval kSpinDuration = 1.0;

@interface BRBuildCellView ()

@property (strong, nonatomic) NSDateFormatter *durationFormatter;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation BRBuildCellView

- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        _durationFormatter = [NSDateFormatter new];
        [_durationFormatter setDateFormat:@"m'm' s's'"];
    }
    
    return self;
}

//- (void)layout {
//    [super layout];
//
//    [self.statusImage setWantsLayer:YES];
//    [self.statusImage setLayerContentsRedrawPolicy:NSViewLayerContentsRedrawOnSetNeedsDisplay];
//    [self.statusImage setCanDrawSubviewsIntoLayer:YES];
//    CALayer *layer = [self.statusImage makeBackingLayer];
//    [self.statusImage setLayer:layer];
//
//    [self setNeedsLayout:YES];
//}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

#pragma mark - Animations -

- (void)spinImage:(BOOL)spin {
    if (spin) {
        // Assign layer
        [self.statusImage setWantsLayer:YES];
        [self.statusImage setLayerContentsRedrawPolicy:NSViewLayerContentsRedrawOnSetNeedsDisplay];
        [self.statusImage setCanDrawSubviewsIntoLayer:YES];
        CALayer *layer = [self.statusImage makeBackingLayer];
        [self.statusImage setLayer:layer];
        
        // Customize layer
        layer.borderColor = [NSColor redColor].CGColor;
        layer.borderWidth = 1.0;
        
        //CGPoint center = CGPointMake(CGRectGetMidX(self.statusImage.frame), CGRectGetMidY(self.statusImage.frame));
        CGPoint center = CGPointMake(layer.superlayer.bounds.size.width / 2, layer.superlayer.bounds.size.height / 2);
        layer.position = center;
        layer.anchorPoint = CGPointMake(0.5, 0.5);
        
        //NSLog(@"Status image layer: %@", NSStringFromRect(layer.bounds), layer.position);
        
        [layer setCornerRadius:self.statusImage.bounds.size.width / 2];
        
        // Build animation
        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 * kSpinDuration ];
        rotationAnimation.duration = kSpinDuration;
        rotationAnimation.cumulative = YES;
        rotationAnimation.repeatCount = HUGE_VALF;
        [layer addAnimation:rotationAnimation forKey:@"transform"];
        
        NSLog(@"Added spin animation: %@, on layer: %@ (%f:%f), center: %f:%f", [layer animationForKey:@"transform"], layer, layer.bounds.size.width, layer.bounds.size.height, layer.position.x, layer.position.y);

    } else {
        [self.statusImage.layer setCornerRadius:0];
        [self.statusImage.layer removeAllAnimations];
    }
}

#pragma mark - Build timer -

- (void)setRunningSince:(NSDate *)startDate {
    void (^buildDurationUpdate)(NSTimer *) = ^void(NSTimer *timer) {
        NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:startDate];
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
