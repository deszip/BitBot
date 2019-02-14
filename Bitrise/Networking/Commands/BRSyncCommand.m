//
//  BRGetBuildsCommand.m
//  BitBot
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRSyncCommand.h"

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
        
        //__weak BREnvironment *weakEnv = _environment;
        //__weak BRLogObserver *weakLogObserver = _logObserver;
        
        __weak BRSyncCommand *weakSelf = self;
        _syncEngine.syncCallback = ^(BRSyncResult *result) {
            // Notifications
            NSArray *builds = [result.diff.started arrayByAddingObjectsFromArray:result.diff.finished];
            [weakSelf.environment postNotifications:builds forApp:result.app];
            
            // Logs
            NSArray *runningBuilds = [result.diff.started arrayByAddingObjectsFromArray:result.diff.running];
            [runningBuilds enumerateObjectsUsingBlock:^(BRBuildInfo *buildInfo, NSUInteger idx, BOOL *stop) {
                [weakSelf.logObserver startObservingBuild:buildInfo.slug];
            }];
            [result.diff.finished enumerateObjectsUsingBlock:^(BRBuildInfo *buildInfo, NSUInteger idx, BOOL *stop) {
                [weakSelf.logObserver stopObservingBuild:buildInfo.slug];
            }];
        };
    }
    
    return self;
}

- (void)execute:(BRCommandResult)callback {
    [self.syncEngine sync];
}

@end
