//
//  BRRebuildCommand.m
//  BitBot
//
//  Created by Deszip on 05/08/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRRebuildCommand.h"

@interface BRRebuildCommand ()

@property (strong, nonatomic) BRBitriseAPI *api;
@property (copy, nonatomic) NSString *appSlug;
@property (copy, nonatomic) NSString *buildToken;
@property (copy, nonatomic) NSString *branch;
@property (copy, nonatomic) NSString *commit;
@property (copy, nonatomic) NSString *workflow;

@end

@implementation BRRebuildCommand

- (instancetype)initWithAPI:(BRBitriseAPI *)api build:(BRBuild *)build {
    if (self = [super init]) {
        _api = api;
        _appSlug = build.app.slug;
        _buildToken = build.app.buildToken;
        _branch = build.branch;
        _commit = build.commitHash;
        _workflow = build.workflow;
    }
    
    return self;
}

- (void)execute:(BRCommandResult)callback {
    [self.api rebuildApp:self.appSlug
              buildToken:self.buildToken
                  branch:self.branch
                  commit:self.commit
                workflow:self.workflow
              completion:^(BOOL status, NSError *error) {
        BR_SAFE_CALL(callback, status, error);
    }];
}

@end
