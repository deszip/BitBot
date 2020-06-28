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

+ (NSFont *)jbMono:(CGFloat)size {
    return [NSFont fontWithName:@"JetBrains Mono" size:size];
}

+ (NSFont *)accountNameFont {   return [BRStyleSheet proximaNova:14.0]; }
+ (NSFont *)appNameFont {       return [BRStyleSheet proximaNova:20.0]; }
+ (NSFont *)buildDetailsFont {  return [BRStyleSheet proximaNova:14.0]; }
+ (NSFont *)accountListFont {   return [BRStyleSheet proximaNova:14.0]; }
+ (NSFont *)emptyTitleFont {    return [BRStyleSheet proximaNova:20.0]; }
+ (NSFont *)emptySubtitleFont { return [BRStyleSheet proximaNova:14.0]; }
+ (NSFont *)aboutTitleFont {    return [BRStyleSheet proximaNova:32.0]; }
+ (NSFont *)aboutVersionFont {  return [BRStyleSheet proximaNova:13.0]; }
+ (NSFont *)aboutTextFont {     return [BRStyleSheet proximaNova:15.0]; }

+ (NSFont *)logFont {           return [BRStyleSheet jbMono:12.0]; }
+ (NSFont *)logStatusFont {     return [BRStyleSheet jbMono:10.0]; }

#pragma mark - Base colors -

+ (NSColor *)backgroundColor {
    return [NSColor colorNamed:@"BackgroundColor"];
}

+ (NSColor *)cellBackgroundColor {
    //return [NSColor colorWithRed:0.11 green:0.13 blue:0.15 alpha:1.0];
    return [NSColor colorNamed:@"CellBackgroundColor"];
}

+ (NSColor *)greenColor {
    //return [NSColor colorWithRed:0.79 green:0.98 blue:0.96 alpha:1.0];
    return [NSColor colorNamed:@"GreenColor"];
}

+ (NSColor *)primaryTextColor {
    //return [NSColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    return [NSColor colorNamed:@"PrimaryTextColor"];
}

+ (NSColor *)secondaryTextColor {
    //return [NSColor colorWithRed:0.78 green:0.85 blue:0.95 alpha:1.0];
    return [NSColor colorNamed:@"SecondaryTextColor"];
}

+ (NSColor *)buildIconTintColor {
    //return NSColorFromRGBA(0xC7DAF3FF);
    return [NSColor colorNamed:@"BuildTintColor"];
}

+ (NSColor *)boxBorderColor {
    return [[BRStyleSheet greenColor] colorWithAlphaComponent:0.5];
}

+ (NSColor *)textColor {
    //return [NSColor colorWithRed:199.0 / 255.0 green:218.0 / 255.0 blue:243.0 / 255.0 alpha:1.0];
    return [NSColor colorNamed:@"TextColor"];
}

#pragma mark - Build colors -

+ (NSColor *)progressColor {
    //return [NSColor colorWithRed:0.506 green:0.318 blue:0.659 alpha:1.0];
    return [NSColor colorNamed:@"BuildProgressColor"];
}

+ (NSColor *)successColor {
    //return [NSColor colorWithRed:0.231 green:0.765 blue:0.639 alpha:1.0];
    return [NSColor colorNamed:@"BuildSuccessColor"];
}

+ (NSColor *)failedColor {
    //return [NSColor colorWithRed:0.941 green:0.455 blue:0.122 alpha:1.0];
    return [NSColor colorNamed:@"BuildFailedColor"];
}

+ (NSColor *)abortedColor {
    //return [NSColor colorWithRed:1 green:0.875 blue:0.051 alpha:1.0];
    return [NSColor colorNamed:@"BuildAbortedColor"];
}

+ (NSColor *)holdColor {
    //return [NSColor colorWithRed:0.004 green:0.263 blue:0.345 alpha:1.0];
    return [NSColor colorNamed:@"BuildHoldColor"];
}

+ (NSColor *)waitingColor {
    //return [NSColor colorWithRed:0.683 green:0.649 blue:0.649 alpha:1.0];
    return [NSColor colorNamed:@"BuildWaitColor"];
}

#pragma mark - UI Constants -

+ (CGFloat)buildIconCorenerRadius { return 8.0; }
+ (CGFloat)accountIconCorenerRadius { return 8.0; }
+ (NSTimeInterval)buildIconSpinDurationSec { return 1.0; }

@end
