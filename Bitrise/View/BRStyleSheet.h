//
//  BRStyleSheet.h
//  Bitrise
//
//  Created by Deszip on 05.04.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRStyleSheet : NSObject

#pragma mark - Base colors -

+ (NSColor *)backgroundColor;
+ (NSColor *)cellBackgroundColor;
+ (NSColor *)greenColor;
+ (NSColor *)primaryTextColor;
+ (NSColor *)secondaryTextColor;

#pragma mark - Build colors -

+ (NSColor *)progressColor;
+ (NSColor *)successColor;
+ (NSColor *)failedColor;
+ (NSColor *)abortedColor;
+ (NSColor *)holdColor;
+ (NSColor *)waitingColor;

@end

NS_ASSUME_NONNULL_END
