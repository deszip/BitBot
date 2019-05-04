//
//  BRRebuildCommand.m
//  BitBot
//
//  Created by Deszip on 05/08/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRRebuildCommand.h"

#import "BRAnalytics.h"
#import "BRRebuildRequest.h"

@interface BRRebuildCommand ()

@property (strong, nonatomic) BRBitriseAPI *api;
@property (copy, nonatomic) NSString *appSlug;
@property (copy, nonatomic) NSString *token;
@property (copy, nonatomic) NSString *branch;
@property (copy, nonatomic) NSString *commit;
@property (copy, nonatomic) NSString *workflow;

@end

@implementation BRRebuildCommand

- (instancetype)initWithAPI:(BRBitriseAPI *)api build:(BRBuild *)build {
    if (self = [super init]) {
        _api = api;
        _appSlug = build.app.slug;
        _token = build.app.account.token;
        _branch = build.branch;
        _commit = build.commitHash;
        _workflow = build.workflow;
    }
    
    return self;
}

- (void)execute:(BRCommandResult)callback {
    BRRebuildRequest *request = [[BRRebuildRequest alloc] initWithToken:self.token appSlug:self.appSlug branch:self.branch];
    [request setCommit:self.commit];
    [request setWorkflow:self.workflow];
    
    [self.api rebuild:request completion:^(BOOL status, NSError * _Nullable error) {
        BR_SAFE_CALL(callback, status, error);
    }];
    
    [[BRAnalytics analytics] trackRebuildAction];
}

@end
