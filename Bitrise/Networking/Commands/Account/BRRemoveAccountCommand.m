//
//  BRRemoveAccountCommand.m
//  BitBot
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRRemoveAccountCommand.h"

@interface BRRemoveAccountCommand ()

@property (strong, nonatomic, readonly) BRBitriseAPI *api;
@property (strong, nonatomic, readonly) BRStorage *storage;
@property (copy, nonatomic) NSString *token;

@end

@implementation BRRemoveAccountCommand

- (instancetype)initWithAPI:(BRBitriseAPI *)api storage:(BRStorage *)storage token:(NSString *)token {
    if (self = [super init]) {
        _api = api;
        _storage = storage;
        _token = token;
    }
    
    return self;
}

- (void)execute:(BRCommandResult)callback {
    [self.storage removeAccount:self.token completion:callback];
}

@end
