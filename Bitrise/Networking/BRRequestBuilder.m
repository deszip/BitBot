//
//  BRRequestBuilder.m
//  BitBot
//
//  Created by Deszip on 25/12/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRRequestBuilder.h"

static NSString * const kAccountInfoEndpoint = @"https://api.bitrise.io/v0.1/me";
static NSString * const kAppsEndpoint = @"https://api.bitrise.io/v0.1/apps";
static NSString * const kBuildsEndpoint = @"https://api.bitrise.io/v0.1/apps/%@/builds";
static NSString * const kAbortEndpoint = @"https://api.bitrise.io/v0.1/apps/%@/builds/%@/abort";
static NSString * const kStartBuildEndpoint = @"https://app.bitrise.io/app/%@/build/start.json";

@implementation BRRequestBuilder

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

- (NSURLRequest *)abortRequest:(NSString *)buildSlug appSlug:(NSString *)appSlug token:(NSString *)token {
    NSURL *endpoint = [NSURL URLWithString:[NSString stringWithFormat:kAbortEndpoint, appSlug, buildSlug]];
    NSMutableURLRequest *request = [[self requestWithEndpoint:endpoint token:token] mutableCopy];
    [request setHTTPMethod:@"POST"];
    NSError *serializationError;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:@{ @"abort_reason": @"foo",
                                                                     @"abort_with_success": @YES,
                                                                     @"skip_notifications": @YES }
                                                          options:0
                                                            error:&serializationError];
    if (requestData) {
        [request setHTTPBody:requestData];
        return [request copy];
    }
    
    return nil;
}

- (NSURLRequest *)rebuildRequest:(NSString *)appSlug
                      buildToken:(NSString *)buildToken
                          branch:(NSString *)branch
                          commit:(NSString *)commit
                        workflow:(NSString *)workflow {
    NSURL *endpoint = [NSURL URLWithString:[NSString stringWithFormat:kStartBuildEndpoint, appSlug]];
    NSMutableURLRequest *request = [[self requestWithEndpoint:endpoint token:nil] mutableCopy];
    [request setHTTPMethod:@"POST"];
    NSError *serializationError;
    
    NSMutableDictionary *params = [@{ @"hook_info": @{ @"type" : @"bitrise",
                                                       @"build_trigger_token" : buildToken },
                                      @"build_params": [@{ @"branch" : branch } mutableCopy] } mutableCopy];
    if (commit) {
        params[@"build_params"][@"commit_hash"] = commit;
    }
    if (workflow) {
        params[@"build_params"][@"workflow_id"] = workflow;
    }

    NSData *requestData = [NSJSONSerialization dataWithJSONObject:params
                                                          options:0
                                                            error:&serializationError];
    if (requestData) {
        [request setHTTPBody:requestData];
        return [request copy];
    }
    
    return nil;
}

- (NSURLRequest *)requestWithEndpoint:(NSURL *)endpoint token:(NSString *)token {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:endpoint];
    if (token) {
        NSString *tokenString = [NSString stringWithFormat:@"token %@", token];
        [request setValue:tokenString forHTTPHeaderField:@"Authorization"];
    }
    
    return [request copy];
}


@end
