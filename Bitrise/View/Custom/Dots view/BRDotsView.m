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

static const NSUInteger kDotSize = 1;
static const NSUInteger kSpacingSize = 5;

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
    [layer.sublayers enumerateObjectsUsingBlock:^(__kindof CALayer *layer, NSUInteger idx, BOOL *stop) {
        [self addMaskTo:layer];
    }];
}

- (CALayer *)buildLayerAtIndex:(NSUInteger)index count:(NSUInteger)count height:(CGFloat)lineHeight spacing:(CGFloat)spacing inRect:(CGRect)rect {
    NSUInteger lineLayerHeight = lineHeight + (spacing * 2);
    
    // Gradient layer setup
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.autoresizingMask = NSViewWidthSizable;
    gradientLayer.startPoint = CGPointMake(0.0, 1.0);
    gradientLayer.endPoint = CGPointMake(1.0, 1.0);
    gradientLayer.locations = @[@(0), @(0.5), @(0.5), @(1.0)];
    NSArray *colors = @[ (id)[[BRStyleSheet greenColor] colorWithAlphaComponent:0.2].CGColor,
                         (id)[BRStyleSheet greenColor].CGColor,
                         (id)[BRStyleSheet greenColor].CGColor,
                         (id)[[BRStyleSheet greenColor] colorWithAlphaComponent:0.2].CGColor ];
    gradientLayer.colors = colors;
    
    // Non-linear width for layers
    CGFloat layerPercentage = 0.0;
    switch (index) {
        case 0: layerPercentage = 0.5; break;
        case 1: layerPercentage = 0.7; break;
        case 2: layerPercentage = 1.0; break;
        default: break;
    }
    
    // We need to align layers so dots are in a same rows
    CGFloat layerWidth = rect.size.width * layerPercentage;
    NSUInteger segmentSize = kDotSize + kSpacingSize;
    double rem = @(layerWidth).integerValue % (segmentSize * 2);
    if (rem > 0) {
        layerWidth -= rem;
    }
    
    // Set margin so that layer is centered
    CGFloat layerMargin = (rect.size.width - layerWidth) / 2.0;
    gradientLayer.frame = CGRectMake(layerMargin, (lineLayerHeight * index) + spacing, layerWidth, lineHeight);
    
    [self addMaskTo:gradientLayer];
    
    NSLog(@"Dot layer #%lu: %f, percentage: %f", (unsigned long)index, layerWidth, layerPercentage);
    
    return gradientLayer;
}

- (void)addMaskTo:(CALayer *)layer {
    CAShapeLayer *maskLayer = [CAShapeLayer new];
    maskLayer.contentsScale = NSScreen.mainScreen.backingScaleFactor;
    maskLayer.frame = CGRectMake(0, 0, layer.bounds.size.width, layer.bounds.size.height);
    maskLayer.strokeColor = [BRStyleSheet greenColor].CGColor;
    maskLayer.lineWidth = layer.bounds.size.height;
    maskLayer.lineDashPattern = @[@(kDotSize), @(kSpacingSize)];
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathMoveToPoint(pathRef, nil, 0, layer.bounds.size.height);
    CGPathAddLineToPoint(pathRef, nil, layer.bounds.size.width, layer.bounds.size.height);
    maskLayer.path = pathRef;
    maskLayer.autoresizingMask = NSViewWidthSizable;
    
    layer.mask = maskLayer;
}

@end
