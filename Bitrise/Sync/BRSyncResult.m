//
//  BRSyncResult.m
//  BitBot
//
//  Created by Deszip on 21/12/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRSyncResult.h"

@implementation BRSyncResult

- (instancetype)initWithApp:(BRAppInfo *)appInfo diff:(BRSyncDiff *)diff {
    if (self = [super init]) {
        _app = appInfo;
        _diff = diff;
    }
    
    return self;
}

@end
