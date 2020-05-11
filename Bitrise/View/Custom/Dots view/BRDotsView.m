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
        NSUInteger lineSpacing = 3.0;
        NSUInteger lineLayerHeight = lineHeight + (lineSpacing * 2);
        NSUInteger lineCount = floor(rect.size.height / lineLayerHeight);
        
        NSLog(@"Adding %lu dot layers...", (unsigned long)lineCount);
        
        for (NSUInteger i = 0; i < lineCount; i++) {
            CALayer *lineLayer = [self buildLayerAtIndex:i count:lineCount height:lineHeight spacing:lineSpacing inRect:rect];
            [self.layer addSublayer:lineLayer];
        }
    }
    
    return self;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [layer.sublayers enumerateObjectsUsingBlock:^(__kindof CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addMask:obj];
    }];
}

- (CALayer *)buildLayerAtIndex:(NSUInteger)index count:(NSUInteger)count height:(CGFloat)lineHeight spacing:(CGFloat)spacing inRect:(CGRect)rect {
    NSUInteger lineLayerHeight = lineHeight + (spacing * 2);
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.autoresizingMask = NSViewWidthSizable;
    gradientLayer.startPoint = CGPointMake(0.0, 1.0);
    gradientLayer.endPoint = CGPointMake(1.0, 1.0);
    gradientLayer.locations = @[@(0), @(0.2), @(0.8), @(1.0)];
    
    CGFloat layerWidth = rect.size.width * (1.0 - (0.1 * (count - index)));
    CGFloat layerMargin = (rect.size.width - layerWidth) / 2.0;
    gradientLayer.frame = CGRectMake(layerMargin, (lineLayerHeight * index) + spacing, layerWidth, lineHeight);
    
    NSLog(@"Dot layer #%lu: %f", (unsigned long)index, layerWidth);
    
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
    maskLayer.lineDashPattern = @[@(1), @(5)];
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathMoveToPoint(pathRef, nil, 0, layer.bounds.size.height);
    CGPathAddLineToPoint(pathRef, nil, layer.bounds.size.width, layer.bounds.size.height);
    maskLayer.path = pathRef;
    maskLayer.autoresizingMask = NSViewWidthSizable;
    
    layer.mask = maskLayer;
}

@end
