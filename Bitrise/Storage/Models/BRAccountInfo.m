//
//  BRAccountResponse.m
//  BitBot
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRAccountInfo.h"

@implementation BRAccountInfo

- (instancetype)initWithResponse:(NSDictionary *)response token:(NSString *)token {
    if (self = [super init]) {
        _rawResponce = response[@"data"];
        _token = token;
        [self parseResponse];
    }
    
    return self;
}

- (instancetype)initWithAccount:(BTRAccount *)account {
    if (self = [super init]) {
        _token = account.token;
        _username = account.username;
        _slug = account.slug;
        _avatarURL = [NSURL URLWithString:account.avatarURL];
        _creationDate = account.creationDate;
        _hasUsedOrgTrial = account.hasUsedOrgTrial;
        _paymentProcessor = account.paymentProcessor;
    }
    
    return self;
}

- (void)parseResponse {
    if (self.rawResponce) {
        _username = self.rawResponce[@"username"];
        _slug = self.rawResponce[@"slug"];
        _avatarURL = [NSURL URLWithString:self.rawResponce[@"avatar_url"]];
        _creationDate = [NSDate date];
        _hasUsedOrgTrial = [self.rawResponce[@"has_used_organization_trial"] boolValue];
        _paymentProcessor = self.rawResponce[@"payment_processor"];
    }
}

@end
