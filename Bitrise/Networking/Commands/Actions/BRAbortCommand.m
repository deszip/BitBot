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
#import "BRBuild+CoreDataClass.h"

@interface BRAbortCommand ()

@property (strong, nonatomic) BRBitriseAPI *api;
@property (strong, nonatomic) BRBuild *build;

@end

@implementation BRAbortCommand

- (instancetype)initWithAPI:(BRBitriseAPI *)api build:(BRBuild *)build {
    if (self = [super init]) {
        _api = api;
        _build = build;
    }
    
    return self;
}

- (void)execute:(BRCommandResult)callback {
    BRAbortRequest *request = [[BRAbortRequest alloc] initWithToken:self.build.app.account.token
                                                            appSlug:self.build.app.slug
                                                          buildSlug:self.build.slug];
    [self.api abortBuild:request completion:^(BOOL status, NSError *error) { BR_SAFE_CALL(callback, status, error); }];
    [[BRAnalytics analytics] trackAbortAction];
}

@end
