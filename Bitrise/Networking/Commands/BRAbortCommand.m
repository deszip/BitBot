//
//  BRAbortCommand.m
//  Bitrise
//
//  Created by Deszip on 05/08/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BRAbortCommand.h"

@interface BRAbortCommand ()

@property (strong, nonatomic) BRBitriseAPI *api;
@property (copy, nonatomic) NSString *appSlug;
@property (copy, nonatomic) NSString *buildSlug;
@property (copy, nonatomic) NSString *token;

@end

@implementation BRAbortCommand

- (instancetype)initWithAPI:(BRBitriseAPI *)api appSlug:(NSString *)appSlug buildSlug:(NSString *)buildSlug token:(NSString *)token {
    if (self = [super init]) {
        _api = api;
        _appSlug = appSlug;
        _buildSlug = buildSlug;
        _token = token;
    }
    
    return self;
}

- (void)execute:(BRCommandResult)callback {
    [self.api abortBuild:self.buildSlug appSlug:self.appSlug token:self.token completion:^(BOOL status, NSError *error) {
        BR_SAFE_CALL(callback, status, error);
    }];
}

@end
