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
@property (assign, nonatomic) BRBuildPageTab tab;
@property (assign, nonatomic, nullable) BREnvironment *environment;

@end

@implementation BROpenBuildCommand

- (instancetype)initWithBuildSlug:(NSString *)buildSlug tab:(BRBuildPageTab)tab environment:(BREnvironment *)environment {
    if (self = [super init]) {
        _buildSlug = buildSlug;
        _tab = tab;
        _environment = environment;
    }
    
    return self;
}

- (void)execute:(BRCommandResult)callback {
    NSMutableString *buildPath = [[NSString stringWithFormat:@"https://app.bitrise.io/build/%@", self.buildSlug] mutableCopy];
    switch (self.tab) {
        case BRBuildPageTabLogs:
            [buildPath appendFormat:@"/#?tab=logs"];
            break;
            
        case BRBuildPageTabArtefacts:
            [buildPath appendFormat:@"/#?tab=artifacts"];
            break;
    }
    
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:buildPath]];
    [self.environment hidePopover];
    
    BR_SAFE_CALL(callback, YES, nil);
    
    [[BRAnalytics analytics] trackOpenBuildAction];
}

@end
