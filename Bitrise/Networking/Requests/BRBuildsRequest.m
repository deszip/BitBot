//
//  BRBuildsRequest.m
//  Bitrise
//
//  Created by Deszip on 10/01/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRBuildsRequest.h"

static NSString * const kAfterKey = @"after";

@implementation BRBuildsRequest

- (instancetype)initWithToken:(NSString *)token appSlug:(NSString *)appSlug syncTime:(NSTimeInterval)syncTime {
    NSURL *endpoint = [NSURL URLWithString:[NSString stringWithFormat:kBuildsEndpoint, appSlug]];
    if (syncTime > 0) {
        NSURLComponents *components = [NSURLComponents componentsWithURL:endpoint resolvingAgainstBaseURL:NO];
        [components setQueryItems:@[[NSURLQueryItem queryItemWithName:kAfterKey value:[@(syncTime) stringValue]]]];
        endpoint = [components URL];
    }
    
    return [super initWithEndpoint:endpoint token:token body:nil];
}

@end
