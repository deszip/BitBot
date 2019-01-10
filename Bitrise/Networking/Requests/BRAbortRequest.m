//
//  BRAbortRequest.m
//  Bitrise
//
//  Created by Deszip on 10/01/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRAbortRequest.h"

static NSString * const kAbortEndpoint = @"https://api.bitrise.io/v0.1/apps/%@/builds/%@/abort";

@implementation BRAbortRequest

- (instancetype)initWithToken:(NSString *)token appSlug:(NSString *)appSlug buildSlug:(NSString *)buildSlug {
    NSURL *endpoint = [NSURL URLWithString:[NSString stringWithFormat:kAbortEndpoint, appSlug, buildSlug]];
    return [super initWithEndpoint:endpoint token:token body:nil];
}

- (NSString *)method {
    return @"POST";
}

- (NSData *)requestBody {
    NSError *serializationError;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:@{ @"abort_reason": @"foo",
                                                                     @"abort_with_success": @YES,
                                                                     @"skip_notifications": @YES }
                                                              options:0
                                                                error:&serializationError];
    
    return requestData;
}


@end
