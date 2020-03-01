//
//  ASOperation.m
//  AppSpector
//
//  Created by Deszip on 24/12/2017.
//  Copyright © 2017 Deszip. All rights reserved.
//

#import "ASOperation.h"

#import "BRLogger.h"

@interface ASOperation ()

@property (assign, nonatomic) NSTimeInterval duration;
@property (assign, nonatomic) BOOL processing;

@end

@implementation ASOperation

- (void)setProcessing:(BOOL)processingState {
    [self trackDuration:processingState];
    
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

- (void)trackDuration:(BOOL)processing {
    NSTimeInterval current = [[NSDate date] timeIntervalSince1970];
    self.duration = processing ? current : current - self.duration;
    if (!processing) {
        BRLog(LL_DEBUG, LL_CORE, @"%@: %f", NSStringFromClass([self class]), self.duration);
    }
}

@end
