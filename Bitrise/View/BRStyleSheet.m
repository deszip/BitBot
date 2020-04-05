//
//  BRStyleSheet.m
//  Bitrise
//
//  Created by Deszip on 05.04.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

#import "BRStyleSheet.h"

@implementation BRStyleSheet

#pragma mark - Base colors -

+ (NSColor *)backgroundColor { return [NSColor colorWithRed:0.09 green:0.11 blue:0.13 alpha:1.0]; }
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

#pragma mark - Build colors -

+ (NSColor *)progressColor {
    return [NSColor colorWithRed:0.51 green:0.32 blue:0.66 alpha:1.0];
}

+ (NSColor *)successColor {
    return [NSColor colorWithRed:0.23 green:0.76 blue:0.64 alpha:1.0];
}

+ (NSColor *)pendingColor {
    return [NSColor colorWithRed:0.0 green:0.26 blue:0.35 alpha:1.0];
}

+ (NSColor *)failedColor {
    return [NSColor colorWithRed:0.94 green:0.45 blue:0.12 alpha:1.0];
}

+ (NSColor *)abortedColor {
    return [NSColor yellowColor];
}

+ (NSColor *)holdColor {
    return [NSColor grayColor];
}

+ (NSColor *)waitingColor {
    return [NSColor blueColor];
}

@end
