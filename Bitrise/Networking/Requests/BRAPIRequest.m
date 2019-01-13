//
//  BRAPIRequest.m
//  Bitrise
//
//  Created by Deszip on 09/01/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRAPIRequest.h"

NSString * const kAccountInfoEndpoint = @"https://api.bitrise.io/v0.1/me";
NSString * const kAppsEndpoint = @"https://api.bitrise.io/v0.1/apps";
NSString * const kBuildsEndpoint = @"https://api.bitrise.io/v0.1/apps/%@/builds";
NSString * const kAbortEndpoint = @"https://api.bitrise.io/v0.1/apps/%@/builds/%@/abort";
NSString * const kStartBuildEndpoint = @"https://api.bitrise.io/v0.1/apps/%@/builds";

@implementation BRAPIRequest

- (instancetype)initWithEndpoint:(NSURL *)endpoint token:(NSString *)token body:(NSData *)body {
    if (self = [super init]) {
        _endpoint = endpoint;
        _token = token;
        _requestBody = body;
    }
    
    return self;
}

- (NSString *)method {
    return @"GET";
}

- (NSURLRequest *)urlRequest {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.endpoint];
    if (self.token) {
        NSString *tokenString = [NSString stringWithFormat:@"token %@", self.token];
        [request setValue:tokenString forHTTPHeaderField:@"Authorization"];
    }
    [request setHTTPBody:[self requestBody]];
    [request setHTTPMethod:[self method]];
    
    return [request copy];
}

@end
