//
//  BRLogsRequest.m
//  Bitrise
//
//  Created by Deszip on 02/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRLogsRequest.h"

static NSString * const kTimestampKey = @"timestamp";
static NSString * const kLimitKey = @"limit";

@interface BRLogsRequest ()

@property (copy, nonatomic) NSString *appSlug;
@property (copy, nonatomic) NSString *buildSlug;

@end

@implementation BRLogsRequest

- (instancetype)initWithToken:(NSString *)token appSlug:(NSString *)appSlug buildSlug:(NSString *)buildSlug since:(NSTimeInterval)syncTime {
    NSURL *endpoint = [NSURL URLWithString:[NSString stringWithFormat:kBuildLogEndpoint, appSlug, buildSlug]];
    if (syncTime >= 0) {
        NSURLComponents *components = [NSURLComponents componentsWithURL:endpoint resolvingAgainstBaseURL:NO];
        [components setQueryItems:@[[NSURLQueryItem queryItemWithName:kTimestampKey value:[@(syncTime) stringValue]]]];
        endpoint = [components URL];
    }
    
    return [super initWithEndpoint:endpoint token:token body:nil];
}

- (NSString *)method {
    return @"GET";
}

@end
