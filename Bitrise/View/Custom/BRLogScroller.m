//
//  BRLogScroller.m
//  Bitrise
//
//  Created by Deszip on 28.06.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

#import "BRLogScroller.h"

#import "BRStyleSheet.h"

static const CGFloat kKnobRadius = 5.0;

@implementation BRLogScroller

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [[NSColor clearColor] setFill];
    NSRectFill(dirtyRect);
    [self drawKnob];
}

- (void)drawKnob {
    [super drawKnob];
    
    NSRect knobRect = NSInsetRect([self rectForPart:NSScrollerKnob], 3, 0);
    NSBezierPath *bezierPath = [NSBezierPath bezierPathWithRoundedRect:knobRect xRadius:kKnobRadius yRadius:kKnobRadius];
    [[BRStyleSheet secondaryTextColor] set];
    [bezierPath fill];
}

@end
