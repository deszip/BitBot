//
//  BRAddAccountOperation.m
//  BitBot
//
//  Created by Deszip on 29/12/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRAddAccountOperation.h"

#import <Sentry/Sentry.h>
#import "BRMacro.h"
#import "BRSyncOperation.h"
#import "BRAccountRequest.h"

@interface BRAddAccountOperation ()

@property (strong, nonatomic) BRStorage *storage;
@property (strong, nonatomic) BRBitriseAPI *api;

@property (copy, nonatomic) NSString *token;

@end

@implementation BRAddAccountOperation

- (instancetype)initWithStorage:(BRStorage *)storage api:(BRBitriseAPI *)api accountToken:(NSString *)token {
    if (self = [super init]) {
        _shallowUpdate = NO;
        _storage = storage;
        _api = api;
        _token = token;
    }
    
    return self;
}

- (void)start {
    [super start];
    
    [self.storage perform:^{
        BRAccountRequest *request = [[BRAccountRequest alloc] initWithToken:self.token];
        [self.api getAccount:request completion:^(BRAccountInfo *accountInfo, NSError *error) {
            if (!accountInfo) {
                BR_SAFE_CALL(self.resultCallback, error);
                [super finish];
                return;
            }
            
            NSError *fetchError;
            BOOL result = [self.storage saveAccount:accountInfo error:&fetchError];
            if (result && !self.shallowUpdate) {
                // Dispatch sync
                BRSyncOperation *syncOperation = [[BRSyncOperation alloc] initWithStorage:self.storage api:self.api];
                [self.queue addOperation:syncOperation];
            }
            
            [super finish];
        }];
    }];
}

@end
