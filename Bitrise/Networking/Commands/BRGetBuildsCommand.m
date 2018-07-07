//
//  BRGetBuildsCommand.m
//  Bitrise
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BRGetBuildsCommand.h"

@interface BRGetBuildsCommand ()

@property (strong, nonatomic) BRBitriseAPI *api;
@property (strong, nonatomic) BRStorage *storage;

@end

@implementation BRGetBuildsCommand

- (instancetype)initWithAPI:(BRBitriseAPI *)api storage:(BRStorage *)storage {
    if (self = [super init]) {
        _api = api;
        _storage = storage;
    }
    
    return self;
}

- (void)execute {
    [self.storage getAccounts:^(NSArray<BRAccountInfo *> *accounts, NSError *error) {
        [accounts enumerateObjectsUsingBlock:^(BRAccountInfo *nextAccount, NSUInteger idx, BOOL *stop) {
            [self.api getBuilds:nextAccount completion:^(NSArray<BRBuildInfo *> *builds, NSError *error) {
                [self.storage saveBuilds:builds];
            }];
        }];
    }];
}

@end
