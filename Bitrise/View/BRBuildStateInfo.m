//
//  BRBuildStateInfo.m
//  Bitrise
//
//  Created by Deszip on 05/08/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BRBuildStateInfo.h"

@implementation BRBuildStateInfo

- (instancetype)initWithBuild:(BRBuild *)build {
    if (self = [super init]) {
        [self applyStatus:build.status.integerValue isOnHold:build.onHold.boolValue];
    }
    
    return self;
}

- (instancetype)initWithBuildInfo:(BRBuildInfo *)buildInfo {
    if (self = [super init]) {
        [self applyStatus:[buildInfo.rawResponse[@"status"] integerValue] isOnHold:[buildInfo.rawResponse[@"is_on_hold"] boolValue]];
    }
    
    return self;
}

- (void)applyStatus:(NSUInteger)buildStatus isOnHold:(BOOL)isOnHold {
    switch (buildStatus) {
        case 0:
            if (isOnHold) {
                self.statusImageName = @"hold-status";
                self.statusTitle = @"On hold";
                self.state = BRBuildStateHold;
            } else {
                self.statusImageName = @"progress-status";
                self.statusTitle = @"In progress...";
                self.state = BRBuildStateInProgress;
            }
            break;
            
        case 1:
            self.statusImageName = @"success-status";
            self.statusTitle = @"Success";
            self.state = BRBuildStateSuccess;
            break;
            
        case 2:
            self.statusImageName = @"failed-status";
            self.statusTitle = @"Failed";
            self.state = BRBuildStateFailed;
            break;
            
        case 3:
            self.statusImageName = @"abort-status";
            self.statusTitle = @"Aborted";
            self.state = BRBuildStateAborted;
            break;
    }
}

@end
