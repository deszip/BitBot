//
//  BRGetBuildsCommand.m
//  Bitrise
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BRSyncCommand.h"

@interface BRSyncCommand ()

@property (strong, nonatomic, readonly) BRSyncEngine *syncEngine;
@property (strong, nonatomic, readonly) BREnvironment *environment;

@end

@implementation BRSyncCommand

- (instancetype)initSyncEngine:(BRSyncEngine *)engine environment:(BREnvironment *)environment {
    if (self = [super init]) {
        _syncEngine = engine;
        _environment = environment;
        
        __weak BREnvironment *weakEnv = _environment;
        _syncEngine.syncCallback = ^(BRSyncResult *result) {
            NSArray *builds = [result.diff.started arrayByAddingObjectsFromArray:result.diff.finished];
            [weakEnv postNotifications:builds forApp:result.app];
        };
    }
    
    return self;
}

- (void)execute:(BRCommandResult)callback {
    [self.syncEngine sync];
}

@end
