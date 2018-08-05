//
//  BRObserver.m
//  Bitrise
//
//  Created by Deszip on 13/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BRObserver.h"

static const NSTimeInterval kObservingTimeout = 10.0;

@interface BRObserver ()

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) BRCommand *command;

@end

@implementation BRObserver

#pragma mark - Public API -

- (void)startObserving:(BRCommand *)command {
    [self stopObserving];
    
    self.command = command;
    [self schedule:self.command];
}

- (void)stopObserving {
    [self.timer invalidate];
    self.command = nil;
}

#pragma mark - Observing -

- (void)schedule:(BRCommand *)command {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kObservingTimeout repeats:YES block:^(NSTimer *timer) {
        [command execute:nil];
    }];
}

@end
