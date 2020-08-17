//
//  BRDisableableScrollView.m
//  Bitrise
//
//  Created by Deszip on 05.08.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

#import "BRDisableableScrollView.h"

@implementation BRDisableableScrollView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (void)scrollWheel:(NSEvent *)event {
    if (self.scrollingEnabled) {
        [super scrollWheel:event];
    } else {
        [self.nextResponder scrollWheel:event];
    }
}

@end
