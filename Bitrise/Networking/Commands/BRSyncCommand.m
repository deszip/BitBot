//
//  BRGetBuildsCommand.m
//  BitBot
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRSyncCommand.h"

#import "BRMacro.h"
#import "BRAnalytics.h"
#import "NSArray+FRP.h"

@interface BRSyncCommand ()

@property (strong, nonatomic, readonly) BRSyncEngine *syncEngine;

@end

@implementation BRSyncCommand

#if TARGET_OS_OSX
- (instancetype)initSyncEngine:(BRSyncEngine *)engine environment:(BREnvironment *)environment {
    if (self = [super init]) {
        _syncEngine = engine;
        
        _syncEngine.syncCallback = ^(BRSyncResult *result) {
            // Notifications
            NSArray *builds = [result.diff.started arrayByAddingObjectsFromArray:result.diff.finished];
            if (builds.count > 0) {
                [environment postNotifications:builds];
            }
            [[BRAnalytics analytics] trackSyncWithStarted:result.diff.started.count
                                                  running:result.diff.running.count
                                                 finished:result.diff.finished.count];
        };
    }
    
    return self;
}
#endif

- (instancetype)initSyncEngine:(BRSyncEngine *)engine {
    if (self = [super init]) {
        _syncEngine = engine;
        _syncEngine.syncCallback = ^(BRSyncResult *result) {
            [[BRAnalytics analytics] trackSyncWithStarted:result.diff.started.count
                                                  running:result.diff.running.count
                                                 finished:result.diff.finished.count];
        };
    }
    return self;
}

- (void)execute:(BRCommandResult)callback {
    [self.syncEngine sync];
}

@end
