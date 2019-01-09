//
//  BRAPIRequest.m
//  Bitrise
//
//  Created by Deszip on 09/01/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRAPIRequest.h"

@implementation BRAPIRequest

- (instancetype)initWithEndpoint:(NSURL *)endpoint token:(NSString *)token body:(NSData *)body {
    if (self = [super init]) {
        _endpoint = endpoint;
        _token = token;
        _requestBody = body;
    }
    
    return self;
}

@end
