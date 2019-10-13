//
//  BRGetBuildsCommand.m
//  BitBot
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRSyncCommand.h"

#import "BRAnalytics.h"
#import "NSArray+FRP.h"

@interface BRSyncCommand ()

@property (strong, nonatomic, readonly) BRSyncEngine *syncEngine;
@property (strong, nonatomic, readonly) BRLogObserver *logObserver;
@property (strong, nonatomic, readonly) BREnvironment *environment;

@end

@implementation BRSyncCommand

- (instancetype)initSyncEngine:(BRSyncEngine *)engine
                   logObserver:(BRLogObserver *)logObserver
                   environment:(BREnvironment *)environment {
    if (self = [super init]) {
        _syncEngine = engine;
        _logObserver = logObserver;
        _environment = environment;
        
        __weak BRSyncCommand *weakSelf = self;
        _syncEngine.syncCallback = ^(BRSyncResult *result) {
            // Notifications
            NSArray *builds = [result.diff.started arrayByAddingObjectsFromArray:result.diff.finished];
            [weakSelf.environment postNotifications:builds forApp:result.app];
            
            // Logs observing
            NSArray *runningBuilds = [result.diff.started arrayByAddingObjectsFromArray:result.diff.running];
            NSSet <NSString *> *runningBuildsSlugs = [NSSet setWithArray:[runningBuilds aps_map:^NSString*(BRBuildInfo *buildInfo) {
                return buildInfo.slug;
            }]];
            
            [runningBuildsSlugs enumerateObjectsUsingBlock:^(NSString *buildSlug, BOOL *stop) {
                [weakSelf.logObserver startObservingBuild:buildSlug];
            }];
            
//            [[BRAnalytics analytics] trackSyncWithStarted:result.diff.started.count
//                                                  running:result.diff.running.count
//                                                 finished:result.diff.finished.count];
        };
    }
    
    return self;
}

- (void)execute:(BRCommandResult)callback {
    [self.syncEngine sync];
}

@end
