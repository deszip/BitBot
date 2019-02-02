//
//  BRLogsRequest.m
//  Bitrise
//
//  Created by Deszip on 02/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRLogsRequest.h"

@interface BRLogsRequest ()

@property (copy, nonatomic) NSString *appSlug;
@property (copy, nonatomic) NSString *buildSlug;

@end

@implementation BRLogsRequest

- (instancetype)initWithToken:(NSString *)token appSlug:(NSString *)appSlug buildSlug:(NSString *)buildSlug {
    NSURL *endpoint = [NSURL URLWithString:[NSString stringWithFormat:kBuildLogEndpoint, appSlug, buildSlug]];
    return [super initWithEndpoint:endpoint token:token body:nil];
}

- (NSString *)method {
    return @"GET";
}

@end
