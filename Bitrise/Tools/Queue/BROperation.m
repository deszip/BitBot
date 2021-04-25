//
//  BROperation.m
//  BitBot
//
//  Created by Deszip on 24/12/2017.
//  Copyright © 2017 Deszip. All rights reserved.
//

#import "BROperation.h"

#import "BRLogger.h"

@interface BROperation ()

@property (assign, nonatomic) NSTimeInterval duration;
@property (assign, nonatomic) BOOL processing;

@end

@implementation BROperation

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
    
    if (processing) {
        _sentryTransaction = [SentrySDK startTransactionWithName:NSStringFromClass([self class]) operation:NSStringFromClass([self class])];
        BRLog(LL_DEBUG, LL_SYNC, @"Started sentry transaction: %@", _sentryTransaction);
    } else {
        [_sentryTransaction finish];
        BRLog(LL_DEBUG, LL_SYNC, @"Finished sentry transaction: %@", _sentryTransaction);
        BRLog(LL_DEBUG, LL_CORE, @"%@: %f", NSStringFromClass([self class]), self.duration);
    }
}

@end
