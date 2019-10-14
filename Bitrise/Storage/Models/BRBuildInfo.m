//
//  BRBuildInfo.m
//  BitBot
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRBuildInfo.h"

@interface BRBuildInfo ()

@end

@implementation BRBuildInfo

- (instancetype)initWithResponse:(NSDictionary *)response {
    if (self = [super init]) {
        _rawResponse = response;
        _stateInfo = [[BRBuildStateInfo alloc] initWithBuildStatus:[response[@"status"] integerValue]
                                                        holdStatus:[response[@"is_on_hold"] boolValue]
                                                           waiting:response[@"started_on_worker_at"] == nil];
        _slug = _rawResponse[@"slug"];
        _appName = _rawResponse[@"slug"];
        _branchName = _rawResponse[@"branch"];
        _workflowName = _rawResponse[@"triggered_workflow"];
    }
    
    return self;
}

- (instancetype)initWithBuild:(BRBuild *)build {
    if (self = [super init]) {
        _rawResponse = nil;
        _stateInfo = [[BRBuildStateInfo alloc] initWithBuildStatus:[build.status integerValue]
                                                        holdStatus:[build.onHold boolValue]
                                                           waiting:[build startTime] == nil];
        _slug = build.slug;
        _appName = build.app.title;
        _branchName = build.branch;
        _workflowName = build.workflow;
    }
    
    return self;
}

@end
