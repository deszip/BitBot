//
//  BRBuildsRequest.m
//  Bitrise
//
//  Created by Deszip on 10/01/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRBuildsRequest.h"

static NSString * const kBuildsEndpoint = @"https://api.bitrise.io/v0.1/apps/%@/builds";

@implementation BRBuildsRequest

- (instancetype)initWithToken:(NSString *)token appSlug:(NSString *)appSlug syncTime:(NSTimeInterval)syncTime {
    NSURL *endpoint = [NSURL URLWithString:[NSString stringWithFormat:kBuildsEndpoint, appSlug]];
    if (syncTime > 0) {
        NSURLComponents *components = [NSURLComponents componentsWithURL:endpoint resolvingAgainstBaseURL:NO];
        [components setQueryItems:@[[NSURLQueryItem queryItemWithName:@"after" value:[@(syncTime) stringValue]]]];
        endpoint = [components URL];
    }
    
    return [super initWithEndpoint:endpoint token:token body:nil];
}

@end
