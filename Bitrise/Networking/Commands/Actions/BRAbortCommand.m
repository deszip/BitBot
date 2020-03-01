//
//  BRAbortCommand.m
//  BitBot
//
//  Created by Deszip on 05/08/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRAbortCommand.h"

#import "BRAnalytics.h"
#import "BRAbortRequest.h"

@interface BRAbortCommand ()

@property (strong, nonatomic) BRBitriseAPI *api;
@property (copy, nonatomic) NSString *appSlug;
@property (copy, nonatomic) NSString *buildSlug;
@property (copy, nonatomic) NSString *token;

@end

@implementation BRAbortCommand

- (instancetype)initWithAPI:(BRBitriseAPI *)api build:(BRBuild *)build {
    if (self = [super init]) {
        _api = api;
        _appSlug = build.app.slug;
        _buildSlug = build.slug;
        _token = build.app.account.token;
    }
    
    return self;
}

- (void)execute:(BRCommandResult)callback {
    BRAbortRequest *request = [[BRAbortRequest alloc] initWithToken:self.token
                                                            appSlug:self.appSlug
                                                          buildSlug:self.buildSlug];
    [self.api abortBuild:request completion:^(BOOL status, NSError *error) {
        BR_SAFE_CALL(callback, status, error);
    }];
    
    [[BRAnalytics analytics] trackAbortAction];
}

@end
