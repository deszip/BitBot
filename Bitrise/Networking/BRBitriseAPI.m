//
//  BRBitriseAPI.m
//  Bitrise
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BRBitriseAPI.h"

static NSString * const kAccountInfoEndpoint = @"https://api.bitrise.io/v0.1/me";
static NSString * const kAppsEndpoint = @"https://api.bitrise.io/v0.1/apps";
static NSString * const kBuildsEndpoint = @"https://api.bitrise.io/v0.1/apps/%@/builds";

typedef void (^APICallback)(NSDictionary * _Nullable, NSError * _Nullable);

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

#pragma mark - API calls -

- (void)getAccount:(NSString *)token completion:(APIAccountInfoCallback)completion {
    [self runRequest:[self accountRequest:token] completion:^(NSDictionary *result, NSError *error) {
        if (result) {
            BRAccountInfo *accountInfo = [[BRAccountInfo alloc] initWithResponse:result token:token];
            completion(accountInfo, nil);
        } else {
            completion(nil, error);
        }
    }];
}

- (void)getApps:(NSString *)token completion:(APIAppsListCallback)completion {
    [self runRequest:[self appsRequest:token] completion:^(NSDictionary *result, NSError *error) {
        if (result) {
            __block NSMutableArray <BRAppInfo *> *apps = [NSMutableArray array];
            [result[@"data"] enumerateObjectsUsingBlock:^(NSDictionary *appData, NSUInteger idx, BOOL *stop) {
                BRAppInfo *appInfo = [[BRAppInfo alloc] initWithResponse:appData];
                [apps addObject:appInfo];
            }];
            completion(apps, nil);
        } else {
            completion(nil, error);
        }
    }];
}

- (void)getBuilds:(NSString *)appSlug token:(NSString *)token after:(NSTimeInterval)after completion:(APIBuildsListCallback)completion {
    [self runRequest:[self buildsRequest:appSlug token:token after:after] completion:^(NSDictionary *result, NSError *error) {
        if (result) {
            __block NSMutableArray <BRBuildInfo *> *builds = [NSMutableArray array];
            [result[@"data"] enumerateObjectsUsingBlock:^(NSDictionary *buildData, NSUInteger idx, BOOL *stop) {
                BRBuildInfo *buildInfo = [[BRBuildInfo alloc] initWithResponse:buildData];
                [builds addObject:buildInfo];
            }];
            completion(builds, nil);
        } else {
            completion(nil, error);
        }
    }];
}

#pragma mark - Request builders -

- (NSURLRequest *)accountRequest:(NSString *)token {
    return [self requestWithEndpoint:[NSURL URLWithString:kAccountInfoEndpoint] token:token];
}

- (NSURLRequest *)appsRequest:(NSString *)token {
    return [self requestWithEndpoint:[NSURL URLWithString:kAppsEndpoint] token:token];
}

- (NSURLRequest *)buildsRequest:(NSString *)slug token:(NSString *)token after:(NSTimeInterval)after {
    NSURL *endpoint = [NSURL URLWithString:[NSString stringWithFormat:kBuildsEndpoint, slug]];
    
    if (after > 0) {
        NSURLComponents *components = [NSURLComponents componentsWithURL:endpoint resolvingAgainstBaseURL:NO];
        [components setQueryItems:@[[NSURLQueryItem queryItemWithName:@"after" value:[@(after) stringValue]]]];
        endpoint = [components URL];
    }
    
    NSURLRequest *request = [self requestWithEndpoint:endpoint token:token];
    
    return request;
}

- (NSURLRequest *)requestWithEndpoint:(NSURL *)endpoint token:(NSString *)token {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:endpoint];
    NSString *tokenString = [NSString stringWithFormat:@"token %@", token];
    [request setValue:tokenString forHTTPHeaderField:@"Authorization"];
    
    return [request copy];
}

#pragma mark - Request processing -

- (void)runRequest:(NSURLRequest *)request completion:(APICallback)completion {
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *urlResponse, NSError *error) {
        if (data) {
            NSError *serializationError = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&serializationError];
            completion(response, nil);
        } else {
            completion(nil, error);
        }
    }];
    
    [task resume];
}

@end
