//
//  BRBitriseAPI.m
//  BitBot
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRBitriseAPI.h"

#import "BRMacro.h"

NSString * const kBRBitriseAPIDomain = @"kBRBitriseAPIDomain";

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

- (void)getAccount:(BRAccountRequest *)request completion:(APIAccountInfoCallback)completion {
    [self runRequest:request.urlRequest completion:^(NSDictionary *result, NSError *error) {
        if (result) {
            BRAccountInfo *accountInfo = [[BRAccountInfo alloc] initWithResponse:result token:request.token];
            completion(accountInfo, nil);
        } else {
            completion(nil, error);
        }
    }];
}

- (void)getApps:(BRAppsRequest *)request completion:(APIAppsListCallback)completion {
    [self runRequest:request.urlRequest completion:^(NSDictionary *result, NSError *error) {
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

- (void)getBuilds:(BRBuildsRequest *)request completion:(APIBuildsListCallback)completion {
    [self runRequest:request.urlRequest completion:^(NSDictionary *result, NSError *error) {
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

- (void)abortBuild:(BRAbortRequest *)request completion:( APIActionCallback)completion {
    [self runRequest:request.urlRequest completion:^(NSDictionary *result, NSError *error) {
        BR_SAFE_CALL(completion, YES, error);
    }];
}

- (void)rebuild:(BRRebuildRequest *)request completion:(APIActionCallback)completion {
    [self runRequest:request.urlRequest completion:^(NSDictionary *response, NSError *error) {
        BR_SAFE_CALL(completion, response != nil, error);
    }];
}

- (void)loadLogs:(BRLogsRequest *)request completion:(APIBuildLogCallback)completion {
    [self runRequest:request.urlRequest completion:^(NSDictionary *response, NSError *error) {
        BRLogInfo *logInfo = [[BRLogInfo alloc] initWithRawLog:response];
        BR_SAFE_CALL(completion, logInfo, error);
    }];
}

#pragma mark - Request processing -

- (void)runRequest:(NSURLRequest *)request completion:(APICallback)completion {
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *urlResponse, NSError *error) {
        NSError *serializationError;
        NSDictionary *response = [self serializedResponse:data urlResponse:urlResponse requestError:error error:&serializationError];
        completion(response, serializationError);
    }];
    
    [task resume];
}

- (NSDictionary *)serializedResponse:(NSData *)data urlResponse:(NSURLResponse *)urlResponse requestError:(NSError *)requestError error:(NSError * __autoreleasing *)error {
    // Get HTTP status
    BOOL statusCodeOK = YES;
    NSUInteger statusCode = 0;
    if ([urlResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        statusCode = [(NSHTTPURLResponse *)urlResponse statusCode];
        statusCodeOK = (statusCode >= 200 && statusCode < 300);
    }
    
    if (data) {
        if (statusCodeOK) {
            // We have response data and status is OK
            return [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
        } else {
            // Status is not ok but we still have reponse, get reason from it
            NSDictionary *reason = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
            if (reason) {
                *error = [NSError errorWithDomain:kBRBitriseAPIDomain code:statusCode userInfo:@{ NSLocalizedDescriptionKey : reason[@"message"] }];
            } else {
                *error = [NSError errorWithDomain:kBRBitriseAPIDomain code:statusCode userInfo:@{ NSLocalizedDescriptionKey : @"Unknown error" }];
            }
            return nil;
        }
    }
    
    // No data
    *error = [NSError errorWithDomain:kBRBitriseAPIDomain code:statusCode userInfo:@{ NSLocalizedDescriptionKey : @"Unknown error" }];
    return nil;
}

@end
