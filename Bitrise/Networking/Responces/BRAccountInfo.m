//
//  BRAccountResponse.m
//  Bitrise
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BRAccountInfo.h"

@interface BRAccountInfo ()

@property (strong, nonatomic) NSDictionary *rawResponce;

@end

@implementation BRAccountInfo

- (instancetype)initWithResponse:(NSDictionary *)response token:(NSString *)token {
    if (self = [super init]) {
        _rawResponce = response;
        _token = token;
        [self parseResponse];
    }
    
    return self;
}

- (instancetype)initWithAccount:(BRAccount *)account {
    if (self = [super init]) {
        _token = account.token;
        _username = account.username;
        _slug = account.slug;
        _avatarURL = [NSURL URLWithString:account.avatarURL];
    }
    
    return self;
}

- (void)parseResponse {
    NSDictionary *responceData = self.rawResponce[@"data"];
    if (responceData) {
        _username = responceData[@"username"];
        _slug = responceData[@"slug"];
        _avatarURL = [NSURL URLWithString:responceData[@"avatar_url"]];
    }
}

@end
