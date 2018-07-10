//
//  BRGetAccountCommand.m
//  Bitrise
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BRGetAccountCommand.h"

@interface BRGetAccountCommand ()

@property (copy, nonatomic) NSString *token;
@property (strong, nonatomic) BRBitriseAPI *api;
@property (strong, nonatomic) BRStorage *storage;

@end

@implementation BRGetAccountCommand

- (instancetype)initWithAPI:(BRBitriseAPI *)api storage:(BRStorage *)storage token:(NSString *)token {
    if (self = [super init]) {
        _token = token;
        _api = api;
        _storage = storage;
    }
    
    return self;
}

- (void)execute {
    [self.api getAccount:self.token completion:^(BRAccountInfo *accountInfo, NSError *error) {
        [self.storage saveAccount:accountInfo];
    }];
    
    // Get apps
    //...
}

@end
