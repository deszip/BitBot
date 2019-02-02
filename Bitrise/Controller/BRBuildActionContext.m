//
//  BRBuildActionContext.m
//  Bitrise
//
//  Created by Deszip on 02/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRBuildActionContext.h"

@implementation BRBuildActionContext

+ (instancetype)contextWithSlug:(NSString *)buildSlug {
    return [[BRBuildActionContext alloc] initWithSlug:buildSlug];
}

- (instancetype)initWithSlug:(NSString *)buildSlug {
    if (self = [super init]) {
        _slug = buildSlug;
    }
    
    return self;
}

@end
