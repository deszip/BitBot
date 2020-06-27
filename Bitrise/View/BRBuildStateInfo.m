//
//  BRBuildStateInfo.m
//  BitBot
//
//  Created by Deszip on 05/08/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRBuildStateInfo.h"

#import "BRStyleSheet.h"

static NSString * const kStateKey = @"kStateKey";
static NSString * const kStatusImageNameKey = @"kStatusImageNameKey";
static NSString * const kNotificationImageNameKey = @"kNotificationImageNameKey";
static NSString * const kStatusTitleKey = @"kStatusTitleKey";
static NSString * const kStatusColorKey = @"kStatusColorKey";

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
                _notificationImageName = @"hold_notification";
                _statusTitle = @"On hold";
                _state = BRBuildStateHold;
                _statusColor = [BRStyleSheet holdColor];
            } else {
                _statusImageName = @"13-degree-status-icon";
                if (isWaiting) {
                    _statusTitle = @"Waiting for worker...";
                    _state = BRBuildStateWaitingForWorker;
                    _statusColor = [BRStyleSheet waitingColor];
                    _notificationImageName = @"unknown_notification";
                } else {
                    _statusTitle = @"In progress...";
                    _state = BRBuildStateInProgress;
                    _statusColor = [BRStyleSheet progressColor];
                    _notificationImageName = @"progress_notification";
                }
            }
            break;
            
        case 1:
            _statusImageName = @"success-status-icon";
            _notificationImageName = @"success_notification";
            _statusTitle = @"Success";
            _state = BRBuildStateSuccess;
            _statusColor = [BRStyleSheet successColor];
            break;
            
        case 2:
            _statusImageName = @"failure-status-icon";
            _notificationImageName = @"failed_notification";
            _statusTitle = @"Failed";
            _state = BRBuildStateFailed;
            _statusColor = [BRStyleSheet failedColor];
            break;
            
        case 3:
        case 4:
            _statusImageName = @"45-degree-status-icon";
            _notificationImageName = @"abort_notification";
            _statusTitle = @"Aborted";
            _state = BRBuildStateAborted;
            _statusColor = [BRStyleSheet abortedColor];
            break;
    }
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:@(self.state) forKey:kStateKey];
    [aCoder encodeObject:self.statusImageName forKey:kStatusImageNameKey];
    [aCoder encodeObject:self.notificationImageName forKey:kNotificationImageNameKey];
    [aCoder encodeObject:self.statusTitle forKey:kStatusTitleKey];
    [aCoder encodeObject:self.statusColor forKey:kStatusColorKey];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    if (self = [super init]) {
        _state = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:kStateKey] integerValue];
        _statusImageName = [aDecoder decodeObjectOfClass:[NSString class] forKey:kStatusImageNameKey];
        _notificationImageName = [aDecoder decodeObjectOfClass:[BRBuildStateInfo class] forKey:kNotificationImageNameKey];
        _statusTitle = [aDecoder decodeObjectOfClass:[NSString class] forKey:kStatusTitleKey];
        _statusColor = [aDecoder decodeObjectOfClass:[NSColor class] forKey:kStatusColorKey];
    }
    
    return self;
}

@end
