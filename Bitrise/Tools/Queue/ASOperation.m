//
//  ASOperation.m
//  AppSpector
//
//  Created by Deszip on 24/12/2017.
//  Copyright © 2017 Deszip. All rights reserved.
//

#import "ASOperation.h"

@interface ASOperation ()

@property (assign, nonatomic) NSTimeInterval duration;
@property (assign, nonatomic) BOOL processing;

@end

@implementation ASOperation

- (void)setProcessing:(BOOL)processingState {
    NSTimeInterval current = [[NSDate date] timeIntervalSince1970];
    self.duration = processingState ? current : current - self.duration;
    if (!processingState) {
        NSLog(@"%@: %f", NSStringFromClass([self class]), self.duration);
    }
    
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
