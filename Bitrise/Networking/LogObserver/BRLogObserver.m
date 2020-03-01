//
//  BRLogObserver.m
//  Bitrise
//
//  Created by Deszip on 30/01/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRLogObserver.h"

#import "BRLogger.h"
#import "NSArray+FRP.h"

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
    @synchronized (self) {
        BRLog(LL_DEBUG, LL_LOGSYNC, @"Observer: %@, build %@, started...", self, buildSlug);
        
        if ([[self operationsForBuild:buildSlug] count] > 0) {
            BRLog(LL_DEBUG, LL_LOGSYNC, @"BRLogObserver: has observing operation: %@, skipping...", buildSlug);
            return;
        }
        
        ASLogObservingOperation *operation = [[ASLogObservingOperation alloc] initWithStorage:self.storage api:self.API buildSlug:buildSlug];
        [self.queue addOperation:operation];
        BRLog(LL_DEBUG, LL_LOGSYNC, @"BRLogObserver: added observing operation: %@", buildSlug);
    }
}

- (void)stopObservingBuild:(NSString *)buildSlug {
    @synchronized (self) {
        [[self operationsForBuild:buildSlug] enumerateObjectsUsingBlock:^(ASOperation <ASLogOperation> *operation, NSUInteger idx, BOOL *stop) {
            BRLog(LL_DEBUG, LL_LOGSYNC, @"BRLogObserver: cancelling observing operation: %@", buildSlug);
            [operation cancel];
        }];
    }
}

- (void)loadLogsForBuild:(NSString *)buildSlug callback:(BRLogLoadingCallback)callback {
    @synchronized (self) {
        ASLogLoadingOperation *operation = [[ASLogLoadingOperation alloc] initWithStorage:self.storage api:self.API buildSlug:buildSlug];
        [operation setLoadingCallback:callback];
        [self.queue addOperation:operation];
        BRLog(LL_DEBUG, LL_LOGSYNC, @"BRLogObserver: added load operation: %@", buildSlug);
    }
}

#pragma mark - Private API -

- (NSArray <ASOperation <ASLogOperation> *> *)operationsForBuild:(NSString *)buildSlug {
    __block NSMutableArray <id<ASLogOperation>> *operations = [NSMutableArray array];
    [self.queue.operations enumerateObjectsUsingBlock:^(id <ASLogOperation> operation, NSUInteger idx, BOOL *stop) {
        if ([[operation buildSlug] isEqualToString:buildSlug]) {
            [operations addObject:operation];
        }
    }];
    
    return operations;
}

@end
