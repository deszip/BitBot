//
//  BRBuild+Mapping.m
//  Bitrise
//
//  Created by Deszip on 08/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BRBuild+Mapping.h"

@implementation BRBuild (Mapping)

+ (EKManagedObjectMapping *)objectMapping {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = EKRFC_3339DatetimeFormat;
    return [EKManagedObjectMapping mappingForEntityName:NSStringFromClass([self class]) withBlock:^(EKManagedObjectMapping *mapping) {
        [mapping mapKeyPath:@"triggered_at" toProperty:@"triggerTime" withDateFormatter:dateFormatter];
        [mapping mapKeyPath:@"started_on_worker_at" toProperty:@"startTime" withDateFormatter:dateFormatter];
        [mapping mapKeyPath:@"environment_prepare_finished_at" toProperty:@"envPrepareFinishedTime" withDateFormatter:dateFormatter];
        [mapping mapKeyPath:@"finished_at" toProperty:@"finishedTime" withDateFormatter:dateFormatter];
        [mapping mapKeyPath:@"slug" toProperty:@"slug"];
        [mapping mapKeyPath:@"status" toProperty:@"status"];
        [mapping mapKeyPath:@"status_text" toProperty:@"statusText"];
        [mapping mapKeyPath:@"abort_reason" toProperty:@"abortReason"];
        [mapping mapKeyPath:@"is_on_hold" toProperty:@"onHold"];
        [mapping mapKeyPath:@"branch" toProperty:@"branch"];
        [mapping mapKeyPath:@"build_number" toProperty:@"buildNumber"];
        [mapping mapKeyPath:@"commit_hash" toProperty:@"commitHash"];
        [mapping mapKeyPath:@"commit_message" toProperty:@"commitMessage"];
        [mapping mapKeyPath:@"tag" toProperty:@"tag"];
        [mapping mapKeyPath:@"triggered_workflow" toProperty:@"workflow"];
        [mapping mapKeyPath:@"triggered_by" toProperty:@"triggeredBy"];
        [mapping mapKeyPath:@"stack_config_type" toProperty:@"stackConfigType"];
        [mapping mapKeyPath:@"stack_identifier" toProperty:@"stackID"];
        [mapping mapKeyPath:@"pull_request_id" toProperty:@"pullRequestID"];
        [mapping mapKeyPath:@"pull_request_target_branch" toProperty:@"pullRequestTargetBranch"];
        [mapping mapKeyPath:@"pull_request_view_url" toProperty:@"pullRequestURL"];
        [mapping mapKeyPath:@"commit_view_url" toProperty:@"commitURL"];
        
        [mapping setPrimaryKey:@"slug"];
    }];
}

@end
