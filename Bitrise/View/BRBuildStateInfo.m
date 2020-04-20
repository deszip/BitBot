//
//  BRBuildStateInfo.m
//  BitBot
//
//  Created by Deszip on 05/08/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRBuildStateInfo.h"

#import "BRStyleSheet.h"

@implementation BRBuildStateInfo

- (instancetype)initWithBuildStatus:(NSUInteger)buildStatus holdStatus:(BOOL)holdStatus waiting:(BOOL)isWaiting {
    if (self = [super init]) {
        [self applyStatus:buildStatus isOnHold:holdStatus waiting:isWaiting];
    }
    
    return self;
}

- (void)applyStatus:(NSUInteger)buildStatus isOnHold:(BOOL)isOnHold waiting:(BOOL)isWaiting {
    switch (buildStatus) {
        case 0:
            if (isOnHold) {
                _statusImageName = @"0-degree-status-icon";
                _statusTitle = @"On hold";
                _state = BRBuildStateHold;
                _statusColor = [BRStyleSheet holdColor];
            } else {
                _statusImageName = @"13-degree-status-icon";
                if (isWaiting) {
                    _statusTitle = @"Waiting for worker...";
                    _state = BRBuildStateWaitingForWorker;
                    _statusColor = [BRStyleSheet waitingColor];
                } else {
                    _statusTitle = @"In progress...";
                    _state = BRBuildStateInProgress;
                    _statusColor = [BRStyleSheet progressColor];
                }
            }
            break;
            
        case 1:
            _statusImageName = @"success-status-icon";
            _statusTitle = @"Success";
            _state = BRBuildStateSuccess;
            _statusColor = [BRStyleSheet successColor];
            break;
            
        case 2:
            _statusImageName = @"failure-status-icon";
            _statusTitle = @"Failed";
            _state = BRBuildStateFailed;
            _statusColor = [BRStyleSheet failedColor];
            break;
            
        case 3:
        case 4:
            _statusImageName = @"45-degree-status-icon";
            _statusTitle = @"Aborted";
            _state = BRBuildStateAborted;
            _statusColor = [BRStyleSheet abortedColor];
            break;
    }
}

@end
