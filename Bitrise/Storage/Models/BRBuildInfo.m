//
//  BRBuildInfo.m
//  BitBot
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRBuildInfo.h"

static NSString * const kRawResponseKey = @"kRawResponseKey";
static NSString * const kAppNameKey = @"kAppNameKey";
static NSString * const kStateInfoKey = @"kStateInfoKey";
static NSString * const kSlugKey = @"kSlugKey";
static NSString * const kBranchNameKey = @"kBranchNameKey";
static NSString * const kWorkflowNameKey = @"kWorkflowNameKey";

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

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:self.rawResponse forKey:kRawResponseKey];
    [aCoder encodeObject:self.appName forKey:kAppNameKey];
    [aCoder encodeObject:self.stateInfo forKey:kStateInfoKey];
    [aCoder encodeObject:self.slug forKey:kSlugKey];
    [aCoder encodeObject:self.branchName forKey:kBranchNameKey];
    [aCoder encodeObject:self.workflowName forKey:kWorkflowNameKey];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    if (self = [super init]) {
        _rawResponse = [aDecoder decodeObjectOfClass:[NSDictionary class] forKey:kRawResponseKey];
        _appName = [aDecoder decodeObjectOfClass:[NSString class] forKey:kAppNameKey];
        _stateInfo = [aDecoder decodeObjectOfClass:[BRBuildStateInfo class] forKey:kStateInfoKey];
        _slug = [aDecoder decodeObjectOfClass:[NSString class] forKey:kSlugKey];
        _branchName = [aDecoder decodeObjectOfClass:[NSString class] forKey:kBranchNameKey];
        _workflowName = [aDecoder decodeObjectOfClass:[NSString class] forKey:kWorkflowNameKey];
    }
    
    return self;
}

@end
