//
//  BRBitriseAPI.m
//  Bitrise
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BRBitriseAPI.h"

#import "BRBuildInfo.h"

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
            BRAccountInfo *accountInfo = [[BRAccountInfo alloc] initWithResponse:response token:token];
            
            completion(accountInfo, nil);
        } else {
            completion(nil, error);
        }
    }];
    
    [task resume];
}

- (void)getBuilds:(BRAccountInfo *)accountInfo completion:(APIBuildsListCallback)completion {
    NSURLRequest *request = [self buildsRequest:accountInfo.slug token:accountInfo.token];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *urlResponse, NSError *error) {
        if (data) {
            NSError *serializationError = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&serializationError];
            __block NSMutableArray *buildsInfo = [NSMutableArray array];
            [response[@"data"] enumerateObjectsUsingBlock:^(NSDictionary *nextBuild, NSUInteger idx, BOOL *stop) {
                BRBuildInfo *buildInfo = [[BRBuildInfo alloc] initWithResponse:nextBuild];
                [buildsInfo addObject:buildInfo];
            }];
            
            completion(buildsInfo, nil);
        } else {
            completion(nil, error);
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
