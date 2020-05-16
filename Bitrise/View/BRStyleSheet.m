//
//  BRStyleSheet.m
//  Bitrise
//
//  Created by Deszip on 05.04.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

#import "BRStyleSheet.h"

/// RGB color macro
#define NSColorFromRGBA(rgbaValue) [NSColor \
    colorWithRed:((float)((rgbaValue & 0xFF000000) >> 24))/255.0 \
    green:((float)((rgbaValue & 0xFF0000) >> 16))/255.0 \
    blue:((float)((rgbaValue & 0xFF00) >> 8)) / 255.0 \
    alpha:(float)(rgbaValue & 0xFF)]

@implementation BRStyleSheet

#pragma mark - Fonts -

+ (NSFont *)proximaNova:(CGFloat)size {
    return [NSFont fontWithName:@"ProximaNova-Regular" size:size];
}

+ (NSFont *)accountNameFont {
    return [BRStyleSheet proximaNova:12.0];
}

+ (NSFont *)appNameFont {
    return [BRStyleSheet proximaNova:20.0];
}

+ (NSFont *)buildDetailsFont {
    return [BRStyleSheet proximaNova:12.0];
}

+ (NSFont *)accountListFont {
    return [BRStyleSheet proximaNova:12.0];
}

#pragma mark - Base colors -

+ (NSColor *)backgroundColor { return [NSColor colorWithRed:22.0 / 255.0 green:27.0 / 255.0 blue:32.0 / 255.0 alpha:1.0]; }
+ (NSColor *)cellBackgroundColor { return [NSColor colorWithRed:0.11 green:0.13 blue:0.15 alpha:1.0]; }

+ (NSColor *)greenColor {
    return [NSColor colorWithRed:0.79 green:0.98 blue:0.96 alpha:1.0];
}

+ (NSColor *)primaryTextColor {
    return [NSColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
}

+ (NSColor *)secondaryTextColor {
    return [NSColor colorWithRed:0.78 green:0.85 blue:0.95 alpha:1.0];
}

+ (NSColor *)buildIconTintColor {
    return NSColorFromRGBA(0xC7DAF3FF);
}

+ (NSColor *)boxBorderColor {
    return [[BRStyleSheet greenColor] colorWithAlphaComponent:0.5];
}

#pragma mark - Build colors -

+ (NSColor *)progressColor {
    return [NSColor colorWithRed:0.506 green:0.318 blue:0.659 alpha:1.0];
}

+ (NSColor *)successColor {
    return [NSColor colorWithRed:0.231 green:0.765 blue:0.639 alpha:1.0];
}

+ (NSColor *)failedColor {
    return [NSColor colorWithRed:0.941 green:0.455 blue:0.122 alpha:1.0];
}

+ (NSColor *)abortedColor {
    return [NSColor colorWithRed:1 green:0.875 blue:0.051 alpha:1.0];
}

+ (NSColor *)holdColor {
    return [NSColor colorWithRed:0.004 green:0.263 blue:0.345 alpha:1.0];
}

+ (NSColor *)waitingColor {
    return [NSColor colorWithRed:0.683 green:0.649 blue:0.649 alpha:1.0];
}

#pragma mark - UI Constants -

+ (CGFloat)buildIconCorenerRadius { return 8.0; }
+ (CGFloat)accountIconCorenerRadius { return 8.0; }
+ (NSTimeInterval)buildIconSpinDurationSec { return 1.0; }

@end
