//
//  BRSyncEngine.m
//  Bitrise
//
//  Created by Deszip on 06/12/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BRSyncEngine.h"

#import "ASQueue.h"
#import "BRSyncOperation.h"
#import "BRAddAccountOperation.h"

@interface BRSyncEngine ()

@property (strong, nonatomic) BRBitriseAPI *API;
@property (strong, nonatomic) BRStorage *storage;

@property (strong, nonatomic) ASQueue *queue;

@end

@implementation BRSyncEngine

- (instancetype)initWithAPI:(BRBitriseAPI *)api storage:(BRStorage *)storage {
    if (self = [super init]) {
        _API = api;
        _storage = storage;
        _queue = [ASQueue new];
        [_queue setMaxConcurrentOperationCount:1];
    }
    
    return self;
}

- (void)sync {
    BRSyncOperation *syncOperation = [[BRSyncOperation alloc] initWithStorage:self.storage api:self.API];
    [syncOperation setSyncCallback:self.syncCallback];
    
    [self.queue addOperation:syncOperation];
}

- (void)addAccount:(NSString *)accountToken {
    BRAddAccountOperation *accountOperation = [[BRAddAccountOperation alloc] initWithStorage:self.storage api:self.API accountToken:accountToken];
    [self.queue addOperation:accountOperation];
}

@end
