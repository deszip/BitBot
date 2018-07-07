//
//  BRBitriseAPI.m
//  Bitrise
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BRBitriseAPI.h"

static NSString * const kAccountInfoEndpoint = @"https://api.bitrise.io/v0.1/me";
static NSString * const kBuildsEndpoint = @"https://api.bitrise.io/v0.1/apps/%@/builds";

@interface BRBitriseAPI ()

@property (strong, nonatomic) NSURLSession *session;

@end

@implementation BRBitriseAPI

- (instancetype)init {
    if (self = [super init]) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
        _session = [NSURLSession sessionWithConfiguration:config];
    }
    
    return self;
}

- (void)getAccount:(NSString *)token completion:(APIAccountInfoCallback)completion {
    NSURLRequest *request = [self accountRequest:token];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *urlResponse, NSError *error) {
        if (data) {
            NSError *serializationError = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&serializationError];
            BRAccountResponse *accountResponse = [[BRAccountResponse alloc] initWithResponse:response token:token];
            
            completion(accountResponse, nil);
        } else {
            completion(nil, error);
        }
    }];
    
    [task resume];
}

- (void)getBuilds:(NSString *)accountSlug token:(NSString *)token {
    NSURLRequest *request = [self buildsRequest:accountSlug token:token];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *urlResponse, NSError *error) {
        if (data) {
            NSError *serializationError = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&serializationError];
            
            //...
        } else {
            //...
        }
    }];
    
    [task resume];
}

#pragma mark - Request builders -

- (NSURLRequest *)accountRequest:(NSString *)token {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kAccountInfoEndpoint]];
    NSString *tokenString = [NSString stringWithFormat:@"token %@", token];
    [request setValue:tokenString forHTTPHeaderField:@"Authorization"];
    
    return [request copy];
}

- (NSURLRequest *)buildsRequest:(NSString *)slug token:(NSString *)token {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kAccountInfoEndpoint]];
    NSString *tokenString = [NSString stringWithFormat:@"token %@", token];
    [request setValue:tokenString forHTTPHeaderField:@"Authorization"];
    
    return [request copy];
}

@end
