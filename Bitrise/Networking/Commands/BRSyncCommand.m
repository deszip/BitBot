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

- (instancetype)initSyncEngine:(BRSyncEngine *)engine
                   logObserver:(BRLogObserver *)logObserver
                   environment:(BREnvironment *)environment {
    if (self = [super init]) {
        _syncEngine = engine;
        
        _syncEngine.syncCallback = ^(BRSyncResult *result) {
            // Notifications
            NSArray *builds = [result.diff.started arrayByAddingObjectsFromArray:result.diff.finished];
            if (builds.count > 0) {
                [environment postNotifications:builds];
            }
            
#if FEATURE_LIVE_LOG
            // Logs observing
            NSArray *runningBuilds = [result.diff.started arrayByAddingObjectsFromArray:result.diff.running];
            NSSet <NSString *> *runningBuildsSlugs = [NSSet setWithArray:[runningBuilds aps_map:^NSString*(BRBuildInfo *buildInfo) {
                return buildInfo.slug;
            }]];

            [runningBuildsSlugs enumerateObjectsUsingBlock:^(NSString *buildSlug, BOOL *stop) {
                [logObserver startObservingBuild:buildSlug];
            }];
#endif
            
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
