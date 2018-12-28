//
//  BRGetAccountCommand.m
//  Bitrise
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BRGetAccountCommand.h"

#import "BRMacro.h"

@interface BRGetAccountCommand ()

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

- (void)execute:(BRCommandResult)callback {
    [self.api getAccount:self.token completion:^(BRAccountInfo *accountInfo, NSError *error) {
        [self.storage saveAccount:accountInfo];
        BR_SAFE_CALL(callback, YES, nil);
    }];
}


@end
