//
//  BRSyncEngine.m
//  BitBot
//
//  Created by Deszip on 06/12/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRSyncEngine.h"

#import "ASQueue.h"
#import "BRSyncOperation.h"
#import "BRAddAccountOperation.h"
#import "BRBitriseAPI.h"

@interface BRSyncEngine ()

@property (strong, nonatomic) BRBitriseAPI *API;
@property (strong, nonatomic) BRStorage *storage;

@property (strong, nonatomic) ASQueue *syncQueue;

@end

@implementation BRSyncEngine

- (instancetype)initWithAPI:(BRBitriseAPI *)api storage:(BRStorage *)storage {
    if (self = [super init]) {
        _API = api;
        _storage = storage;
        
        _syncQueue = [ASQueue new];
        [_syncQueue setMaxConcurrentOperationCount:1];
    }
    
    return self;
}

- (void)sync {
    BRSyncOperation *syncOperation = [[BRSyncOperation alloc] initWithStorage:self.storage api:self.API];
    [syncOperation setSyncCallback:self.syncCallback];
    
    [self.syncQueue addOperation:syncOperation];
}

- (void)addAccount:(NSString *)accountToken callback:(BRAddAccountCallback)callback {
    BRAddAccountOperation *accountOperation = [[BRAddAccountOperation alloc] initWithStorage:self.storage api:self.API accountToken:accountToken];
    [accountOperation setResultCallback:callback];
    [self.syncQueue addOperation:accountOperation];
}

@end
