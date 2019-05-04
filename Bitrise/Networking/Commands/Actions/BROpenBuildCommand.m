//
//  BROpenBuildCommand.m
//  BitBot
//
//  Created by Deszip on 05/08/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BROpenBuildCommand.h"

#import "BRAnalytics.h"

@interface BROpenBuildCommand ()

@property (copy, nonatomic) NSString *buildSlug;

@end

@implementation BROpenBuildCommand

- (instancetype)initWithBuildSlug:(NSString *)buildSlug {
    if (self = [super init]) {
        _buildSlug = buildSlug;
    }
    
    return self;
}

- (void)execute:(BRCommandResult)callback {
    NSString *buildPath = [NSString stringWithFormat:@"https://app.bitrise.io/build/%@", self.buildSlug];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:buildPath]];
    
    BR_SAFE_CALL(callback, YES, nil);
    
    [[BRAnalytics analytics] trackOpenBuildAction];
}

@end
