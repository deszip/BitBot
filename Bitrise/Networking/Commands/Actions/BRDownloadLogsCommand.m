//
//  BRDownloadLogsCommand.m
//  BitBot
//
//  Created by Deszip on 05/08/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRDownloadLogsCommand.h"

#import "BRAnalytics.h"

@interface BRDownloadLogsCommand ()

@property (copy, nonatomic) NSString *buildSlug;

@end

@implementation BRDownloadLogsCommand

- (instancetype)initWithBuildSlug:(NSString *)buildSlug {
    if (self = [super init]) {
        _buildSlug = buildSlug;
    }
    
    return self;
}

- (void)execute:(BRCommandResult)callback {
    NSString *downloadPath = [NSString stringWithFormat:@"https://app.bitrise.io/api/build/%@/logs.json?&download=log", self.buildSlug];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:downloadPath]];
    
    BR_SAFE_CALL(callback, YES, nil);
    
    [[BRAnalytics analytics] trackLoadLogsAction];
}

@end
