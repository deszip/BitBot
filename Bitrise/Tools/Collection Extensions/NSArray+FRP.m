//
//  NSArray+FRP.m
//  AppSpectorSDK
//
//  Created by Deszip on 25/07/2017.
//  Copyright © 2017 Techery. All rights reserved.
//

#import "NSArray+FRP.h"

@implementation NSArray (FRP)

- (id)aps_map:(id (^)(id obj))map {
    NSMutableArray *results = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [results addObject:map(obj)];
    }];
    
    return [results copy];
}

- (instancetype)aps_filter:(BOOL (^)(id))filter {
    NSMutableArray *results = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (filter(obj)) {
            [results addObject:obj];
        }
    }];
    
    return [results copy];
}


@end
