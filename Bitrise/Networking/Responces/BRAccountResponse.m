//
//  BRAccountResponse.m
//  Bitrise
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BRAccountResponse.h"

@interface BRAccountResponse ()

@property (strong, nonatomic) NSDictionary *rawResponce;

@end

@implementation BRAccountResponse

- (instancetype)initWithResponse:(NSDictionary *)response token:(NSString *)token {
    if (self = [super init]) {
        _rawResponce = response;
        _token = token;
        [self parseResponse];
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
