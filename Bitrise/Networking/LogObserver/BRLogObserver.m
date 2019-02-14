//
//  BRLogObserver.m
//  Bitrise
//
//  Created by Deszip on 30/01/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRLogObserver.h"

#import "ASQueue.h"
#import "ASLogLoadingOperation.h"
#import "ASLogObservingOperation.h"

@interface BRLogObserver ()

@property (strong, nonatomic) BRBitriseAPI *API;
@property (strong, nonatomic) BRStorage *storage;

@property (strong, nonatomic) ASQueue *queue;

@end

@implementation BRLogObserver

- (instancetype)initWithAPI:(BRBitriseAPI *)api storage:(BRStorage *)storage {
    if (self = [super init]) {
        _API = api;
        _storage = storage;
        _queue = [ASQueue new];
    }
    
    return self;
}

- (void)startObservingBuild:(NSString *)buildSlug {
    NSLog(@"Observer: %@, build %@, started...", self, buildSlug);
    
    ASLogObservingOperation *oldOperation = [self operationForBuild:buildSlug];
    if (oldOperation) {
        NSLog(@"BRLogObserver: has observing operation: %@, skipping...", buildSlug);
        return;
    }
    
    ASLogObservingOperation *operation = [[ASLogObservingOperation alloc] initWithStorage:self.storage api:self.API buildSlug:buildSlug];
    [self.queue addOperation:operation];
    NSLog(@"BRLogObserver: added observing operation: %@", buildSlug);
}

- (void)stopObservingBuild:(NSString *)buildSlug {
    ASLogObservingOperation *operation = [self operationForBuild:buildSlug];
    if (operation) {
        NSLog(@"BRLogObserver: cancelling observing operation: %@", buildSlug);
        [operation cancel];
    }
}

- (void)loadLogsForBuild:(NSString *)buildSlug {
    ASLogLoadingOperation *operation = [[ASLogLoadingOperation alloc] initWithStorage:self.storage api:self.API buildSlug:buildSlug];
    [self.queue addOperation:operation];
    NSLog(@"BRLogObserver: added load operation: %@", buildSlug);
}

- (ASLogObservingOperation *)operationForBuild:(NSString *)buildSlug {
    __block ASLogObservingOperation *targetOperation = nil;
    [self.queue.operations enumerateObjectsUsingBlock:^(ASOperation* operation, NSUInteger idx, BOOL *stop) {
        if ([operation isKindOfClass:[ASLogObservingOperation class]]) {
            if ([[(ASLogObservingOperation *)operation buildSlug] isEqualToString:buildSlug]) {
                *stop = YES;
                targetOperation = (ASLogObservingOperation *)operation;
            }
        }
    }];
    
    return targetOperation;
}

@end
