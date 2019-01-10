//
//  BRRebuildRequest.m
//  Bitrise
//
//  Created by Deszip on 09/01/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRRebuildRequest.h"

static NSString * const kStartBuildEndpoint = @"https://api.bitrise.io/v0.1/apps/%@/builds";

@implementation BRRebuildRequest

- (instancetype)initWithToken:(NSString *)token appSlug:(NSString *)appSlug branch:(NSString *)branch {
    NSURL *endpoint = [NSURL URLWithString:[NSString stringWithFormat:kStartBuildEndpoint, appSlug]];
    if (self = [super initWithEndpoint:endpoint token:token body:nil]) {
        _branch = branch;
    }
    
    return self;
}

- (NSString *)method {
    return @"POST";
}

- (NSData *)requestBody {
    NSError *serializationError;
    NSMutableDictionary *params = [@{ @"hook_info":     @{ @"type" : @"bitrise" },
                                      @"build_params":  [@{ @"branch" : self.branch } mutableCopy],
                                      @"triggered_by":  @"bitrise_api_doc" } mutableCopy];
    if (self.commit) {
        params[@"build_params"][@"commit_hash"] = self.commit;
    }
    if (self.workflow) {
        params[@"build_params"][@"workflow_id"] = self.workflow;
    }
    
    return [NSJSONSerialization dataWithJSONObject:params options:0 error:&serializationError];
}

@end
