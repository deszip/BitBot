//
//  BRAddAccountOperation.m
//  BitBot
//
//  Created by Deszip on 29/12/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRAddAccountOperation.h"

#import "BRSyncOperation.h"

@interface BRAddAccountOperation ()

@property (strong, nonatomic) BRStorage *storage;
@property (strong, nonatomic) BRBitriseAPI *api;

@property (copy, nonatomic) NSString *token;

@end

@implementation BRAddAccountOperation

- (instancetype)initWithStorage:(BRStorage *)storage api:(BRBitriseAPI *)api accountToken:(NSString *)token {
    if (self = [super init]) {
        _storage = storage;
        _api = api;
        _token = token;
    }
    
    return self;
}

- (void)start {
    [super start];
    
    [self.storage perform:^{
        [self.api getAccount:self.token completion:^(BRAccountInfo *accountInfo, NSError *error) {
            if (!accountInfo) {
                [super finish];
                return;
            }
            
            NSError *fetchError;
            BOOL result = [self.storage saveAccount:accountInfo error:&fetchError];
            if (result) {
                // Dispatch sync
                BRSyncOperation *syncOperation = [[BRSyncOperation alloc] initWithStorage:self.storage api:self.api];
                [self.queue addOperation:syncOperation];
            }
            
            [super finish];
        }];
    }];
}

@end
