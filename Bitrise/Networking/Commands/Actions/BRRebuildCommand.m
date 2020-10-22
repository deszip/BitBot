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
#import "BRBuild+CoreDataClass.h"

@interface BRRebuildCommand ()

@property (strong, nonatomic) BRBitriseAPI *api;
@property (strong, nonatomic) BRBuild *build;

@end

@implementation BRRebuildCommand

- (instancetype)initWithAPI:(BRBitriseAPI *)api build:(BRBuild *)build {
    if (self = [super init]) {
        _api = api;
        _build = build;
    }
    
    return self;
}

- (void)execute:(BRCommandResult)callback {
    BRRebuildRequest *request = [[BRRebuildRequest alloc] initWithToken:self.build.app.account.token
                                                                appSlug:self.build.app.slug
                                                                 branch:self.build.branch];
    [request setCommit:self.build.commitHash];
    [request setWorkflow:self.build.workflow];
    
    [self.api rebuild:request completion:^(BOOL status, NSError * _Nullable error) {
        BR_SAFE_CALL(callback, status, error);
    }];
    
    [[BRAnalytics analytics] trackRebuildAction];
}

@end
