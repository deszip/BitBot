//
//  BRDotsView.m
//  Bitrise
//
//  Created by Deszip on 03.05.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

#import "BRDotsView.h"

#import <QuartzCore/QuartzCore.h>
#import "BRStyleSheet.h"

@implementation BRDotsView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        
        NSRect rect = self.frame;
        CALayer *rootLayer = [CALayer new];
        [rootLayer setFrame:rect];
        [self setLayer:rootLayer];
        [self setWantsLayer:YES];
        
        NSUInteger lineHeight = 1.0;
        NSUInteger lineSpacing = 2.0;
        NSUInteger lineLayerHeight = lineHeight + (lineSpacing * 2);
        NSUInteger lineCount = floor(rect.size.height / lineLayerHeight);
        
        for (NSUInteger i = 0; i < lineCount; i++) {
            CALayer *lineLayer = [self buildLayerAtIndex:i height:lineHeight spacing:lineSpacing inRect:rect];
            [self.layer addSublayer:lineLayer];
        }
    }
    
    return self;
}

- (CALayer *)buildLayerAtIndex:(NSUInteger)index height:(CGFloat)lineHeight spacing:(CGFloat)spacing inRect:(CGRect)rect {
    NSUInteger lineLayerHeight = lineHeight + (spacing * 2);
    
    CAShapeLayer *layer = [CAShapeLayer new];
    
    [layer setFrame:CGRectMake(0, 0, rect.size.width, lineLayerHeight)];
    
    layer.strokeColor = [BRStyleSheet greenColor].CGColor;
    layer.lineWidth = lineHeight;
    layer.lineDashPattern = @[@(lineHeight), @(lineHeight)];
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathMoveToPoint(pathRef, nil, 0, lineHeight);
    CGPathAddLineToPoint(pathRef, nil, layer.frame.size.width, lineHeight);
    layer.path = pathRef;
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.startPoint = CGPointMake(0.0, 1.0);
    gradientLayer.endPoint = CGPointMake(1.0, 1.0);
    gradientLayer.locations = @[@(0), @(0.2), @(0.8), @(1.0)];
    gradientLayer.frame = CGRectMake(0, (lineLayerHeight * index) + spacing, rect.size.width, lineHeight);;
    NSArray *colors = @[ (id)[NSColor clearColor].CGColor,
                         (id)[BRStyleSheet greenColor].CGColor,
                         (id)[BRStyleSheet greenColor].CGColor,
                         (id)[NSColor clearColor].CGColor ];
    gradientLayer.colors = colors;
    [gradientLayer setMask:layer];

    return gradientLayer;
}

@end
