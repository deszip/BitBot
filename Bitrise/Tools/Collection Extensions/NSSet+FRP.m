//
//  NSSet+FRP.m
//  AppSpectorSDK
//
//  Created by Deszip on 12/09/2017.
//  Copyright © 2017 Techery. All rights reserved.
//

#import "NSSet+FRP.h"

@implementation NSSet (FRP)

- (id)aps_map:(id (^)(id obj))map {
    NSMutableSet *results = [NSMutableSet set];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        [results addObject:map(obj)];
    }];
    
    return [results copy];
}

- (NSSet *)aps_filter:(BOOL (^)(id))filter {
    NSMutableSet *results = [NSMutableSet set];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (filter(obj)) {
            [results addObject:obj];
        }
    }];
    
    return [results copy];
}

@end
