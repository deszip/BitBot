//
//  BRAboutTextView.m
//  Bitrise
//
//  Created by Deszip on 06/01/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRAboutTextView.h"

@implementation BRAboutTextView

- (void)setAutomaticLinkDetectionEnabled:(BOOL)automaticLinkDetectionEnabled {
    [super setAutomaticLinkDetectionEnabled:automaticLinkDetectionEnabled];
    if (automaticLinkDetectionEnabled) {
        [self highliteLinks];
    }
}

- (void)highliteLinks {
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    if (!linkDetector) {
        return;
    }
    
    NSArray *matches = [linkDetector matchesInString:self.string options:0 range:NSMakeRange(0, self.string.length)];
    [self.textStorage beginEditing];
    for (NSTextCheckingResult *match in matches) {
        if (!match.URL) continue;
        NSDictionary *linkAttributes = @{ NSLinkAttributeName: match.URL };
        [self.textStorage addAttributes:linkAttributes range:match.range];
    }
    [self.textStorage endEditing];
}

@end
