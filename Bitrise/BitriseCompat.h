//
//  BitriseCompat.h
//  Bitrise
//
//  Created by Vladislav Sosiuk on 30.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

#import "TargetConditionals.h"

#if TARGET_OS_OSX
    #import <AppKit/AppKit.h>
#else
    #import <UIKit/UIKit.h>
#endif

#if !TARGET_OS_OSX
    #ifndef NSColor
        #define NSColor UIColor
    #endif
    #ifndef NSFont
        #define NSFont UIFont
    #endif
#endif
