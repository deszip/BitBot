//
//  ASOperation.m
//  AppSpector
//
//  Created by Deszip on 24/12/2017.
//  Copyright © 2017 Deszip. All rights reserved.
//

#import "ASOperation.h"

@interface ASOperation ()

@property (assign, nonatomic) BOOL processing;

@end

@implementation ASOperation

- (void)setProcessing:(BOOL)processingState {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    _processing = processingState;
    
    [self didChangeValueForKey:@"isFinished"];
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isFinished {
    return !self.processing;
}

- (BOOL)isExecuting {
    return self.processing;
}

- (void)start {
    if (self.isCancelled) {
        return;
    }
    
    [self setProcessing:YES];
}

- (void)cancel {
    [self finish];
}

- (void)finish {
    [self setProcessing:NO];
}

@end
