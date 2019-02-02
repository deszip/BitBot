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
    ASLogLoadingOperation *operation = [[ASLogLoadingOperation alloc] initWithStorage:self.storage api:self.API buildSlug:buildSlug];
    [self.queue addOperation:operation];
    NSLog(@"BRLogObserver: added operation: %@", buildSlug);
}

- (void)stopObservingBuild:(NSString *)buildSlug {
    [self.queue.operations enumerateObjectsUsingBlock:^(ASLogLoadingOperation* operation, NSUInteger idx, BOOL *stop) {
        if ([operation.buildSlug isEqualToString:buildSlug]) {
            NSLog(@"BRLogObserver: cancelling operation: %@", buildSlug);
            [operation cancel];
        }
    }];
}

@end
