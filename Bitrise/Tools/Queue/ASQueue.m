//
//  ASQueue.m
//  AppSpector
//
//  Created by Deszip on 22/12/2017.
//  Copyright © 2017 Deszip. All rights reserved.
//

#import "ASQueue.h"

#import "BROperation.h"

static dispatch_queue_t underlyingQueue;

@implementation ASQueue

- (instancetype)init {
    if (self = [super init]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT, QOS_CLASS_DEFAULT, DISPATCH_QUEUE_PRIORITY_DEFAULT);
            underlyingQueue = dispatch_queue_create("com.bitrise.sync-queue", attr);
        });
        
        [self setUnderlyingQueue:underlyingQueue];
    }
    
    return self;
}

- (void)addOperation:(NSOperation *)op {
    if ([op isKindOfClass:[BROperation class]]) {
        [(BROperation *)op setQueue:self];
    }
    
    [super addOperation:op];
}

@end
