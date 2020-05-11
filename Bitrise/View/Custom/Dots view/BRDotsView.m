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

@interface BRDotsView() <CALayerDelegate>

@end

@implementation BRDotsView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        
        [self setLayerContentsRedrawPolicy:NSViewLayerContentsRedrawDuringViewResize];
        
        NSRect rect = self.frame;
        CALayer *rootLayer = [CALayer new];
        [rootLayer setFrame:rect];
        [rootLayer setDelegate:self];
        
        [self setLayer:rootLayer];
        [self setWantsLayer:YES];
        
        /// Dot layer builder
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

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    
    NSLog(@"Frame: %f", layer.frame.size.width);
    NSLog(@"Bounds: %f", layer.bounds.size.width);
    NSLog(@"Sublayers: %@", layer.sublayers);
    
    [layer.sublayers enumerateObjectsUsingBlock:^(__kindof CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addMask:obj];
        NSLog(@"    Frame: %f / %f", obj.frame.size.width, obj.mask.frame.size.width);
        NSLog(@"    Bounds: %f / %f", obj.bounds.size.width, obj.mask.bounds.size.width);
    }];
}

- (CALayer *)buildLayerAtIndex:(NSUInteger)index height:(CGFloat)lineHeight spacing:(CGFloat)spacing inRect:(CGRect)rect {
    NSUInteger lineLayerHeight = lineHeight + (spacing * 2);
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.autoresizingMask = NSViewWidthSizable;
    gradientLayer.startPoint = CGPointMake(0.0, 1.0);
    gradientLayer.endPoint = CGPointMake(1.0, 1.0);
    gradientLayer.locations = @[@(0), @(0.2), @(0.8), @(1.0)];
    gradientLayer.frame = CGRectMake(0, (lineLayerHeight * index) + spacing, rect.size.width, lineHeight);
    NSArray *colors = @[ (id)[NSColor clearColor].CGColor,
                         (id)[BRStyleSheet greenColor].CGColor,
                         (id)[BRStyleSheet greenColor].CGColor,
                         (id)[NSColor clearColor].CGColor ];
    gradientLayer.colors = colors;
    
    [self addMask:gradientLayer];
    
    return gradientLayer;
}

- (void)addMask:(CALayer *)layer {
    CAShapeLayer *maskLayer = [CAShapeLayer new];
    maskLayer.contentsScale = NSScreen.mainScreen.backingScaleFactor;
    maskLayer.frame = CGRectMake(0, 0, layer.bounds.size.width, layer.bounds.size.height);
    maskLayer.strokeColor = [BRStyleSheet greenColor].CGColor;
    maskLayer.lineWidth = layer.bounds.size.height;
    maskLayer.lineDashPattern = @[@(layer.bounds.size.height), @(layer.bounds.size.height)];
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathMoveToPoint(pathRef, nil, 0, layer.bounds.size.height);
    CGPathAddLineToPoint(pathRef, nil, layer.bounds.size.width, layer.bounds.size.height);
    maskLayer.path = pathRef;
    maskLayer.autoresizingMask = NSViewWidthSizable;
    
    layer.mask = maskLayer;
}

@end
