//
//  BRRemoveAccountCommand.m
//  Bitrise
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BRRemoveAccountCommand.h"

@interface BRRemoveAccountCommand ()

@property (copy, nonatomic) NSString *token;
@property (strong, nonatomic) BRStorage *storage;

@end

@implementation BRRemoveAccountCommand

- (instancetype)initWithStorage:(BRStorage *)storage token:(NSString *)token {
    if (self = [super init]) {
        _token = token;
        _storage = storage;
    }
    
    return self;
}

- (void)execute {
    [self.storage removeAccount:self.token];
}

@end
