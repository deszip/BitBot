//
//  BRGetAccountCommand.m
//  BitBot
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRGetAccountCommand.h"

#import "BRAnalytics.h"
#import "BRMacro.h"

@interface BRGetAccountCommand ()

@property (strong, nonatomic, readonly) BRSyncEngine *syncEngine;
@property (strong, nonatomic, readonly) BRBitriseAPI *api;
@property (strong, nonatomic, readonly) BRStorage *storage;
@property (copy, nonatomic) NSString *token;

@end

@implementation BRGetAccountCommand

- (instancetype)initWithAPI:(BRBitriseAPI *)api storage:(BRStorage *)storage token:(NSString *)token {
    if (self = [super init]) {
        _api = api;
        _storage = storage;
        _token = token;
    }
    
    return self;
}

- (instancetype)initWithSyncEngine:(BRSyncEngine *)engine token:(NSString *)token {
    if (self = [super init]) {
        _syncEngine = engine;
        _token = token;
    }
    
    return self;
}

- (void)execute:(BRCommandResult)callback {
    [self.syncEngine addAccount:self.token callback:^(NSError * _Nullable error) {
        callback(error == nil, error);
        if (error) {
            [[BRAnalytics analytics] trackAccountAddFailure:error];
        } else {
            [[BRAnalytics analytics] trackAccountAdd];
        }
    }];
}

@end
