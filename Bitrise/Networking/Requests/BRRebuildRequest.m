//
//  BRRebuildRequest.m
//  Bitrise
//
//  Created by Deszip on 09/01/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRRebuildRequest.h"

static NSString * const kHookInfoKey        = @"hook_info";
static NSString * const kHookInfoTypeKey    = @"type";
static NSString * const kParamsKey          = @"build_params";
static NSString * const kBranchKey          = @"branch";
static NSString * const kCommitKey          = @"commit_hash";
static NSString * const kWorkflowKey        = @"workflow_id";
static NSString * const kTriggerKey         = @"triggered_by";

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
    NSMutableDictionary *params = [@{ kHookInfoKey: @{ kHookInfoTypeKey : @"bitrise" },
                                      kParamsKey:   [@{ kBranchKey : self.branch } mutableCopy],
                                      kTriggerKey:  @"bitbot" } mutableCopy];
    if (self.commit) {
        params[kParamsKey][kCommitKey] = self.commit;
    }
    if (self.workflow) {
        params[kParamsKey][kWorkflowKey] = self.workflow;
    }
    
    return [NSJSONSerialization dataWithJSONObject:params options:0 error:&serializationError];
}

@end
