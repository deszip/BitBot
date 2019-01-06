//
//  BRSyncDiff.m
//  BitBot
//
//  Created by Deszip on 21/12/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRSyncDiff.h"

@implementation BRSyncDiff

- (instancetype)initWithStartedBuilds:(NSArray <BRBuildInfo *> *)started finishedBuilds:(NSArray <BRBuildInfo *> *)finished {
    if (self = [super init]) {
        _started = started;
        _finished = finished;
    }
    
    return self;
}


@end
