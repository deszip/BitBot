//
//  BRMacro.h
//  BitBot
//
//  Created by Deszip on 18/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#ifndef BRMacro_h
#define BRMacro_h

#pragma mark - Tools -

#define BR_SAFE_CALL(block, ...) block ? block(__VA_ARGS__) : nil

//RGB color macro
#define NSColorFromRGB(rgbValue) [NSColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
 
//RGB color macro with alpha
#define NSColorFromRGBWithAlpha(rgbValue,a) [NSColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

#pragma mark - Features -

#define FEATURE_LIVE_LOG 0

#endif /* BRMacro_h */
