//
//  ASQueue.m
//  AppSpector
//
//  Created by Deszip on 22/12/2017.
//  Copyright © 2017 Deszip. All rights reserved.
//

#import "ASQueue.h"

#import "ASOperation.h"

@implementation ASQueue

- (void)addOperation:(NSOperation *)op {
    if ([op isKindOfClass:[ASOperation class]]) {
        [(ASOperation *)op setQueue:self];
    }
    
    [super addOperation:op];
}

@end
