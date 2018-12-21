//
//  BRBuildInfo.m
//  Bitrise
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BRBuildInfo.h"

@interface BRBuildInfo ()

@end

@implementation BRBuildInfo

- (instancetype)initWithResponse:(NSDictionary *)response {
    if (self = [super init]) {
        _rawResponse = response;
        _stateInfo = [[BRBuildStateInfo alloc] initWithBuildStatus:[response[@"status"] integerValue] holdStatus:[response[@"is_on_hold"] boolValue]];
        _slug = _rawResponse[@"slug"];
    }
    
    return self;
}

- (instancetype)initWithBuild:(BRBuild *)build {
    if (self = [super init]) {
        _rawResponse = nil;
        _stateInfo = [[BRBuildStateInfo alloc] initWithBuildStatus:[build.status integerValue] holdStatus:[build.onHold boolValue]];
        _slug = build.slug;
    }
    
    return self;
}

@end
