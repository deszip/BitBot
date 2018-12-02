//
//  NSDictionary+FRP.m
//  AppSpectorSDK
//
//  Created by Deszip on 19/09/2017.
//  Copyright © 2017 Techery. All rights reserved.
//

#import "NSDictionary+FRP.h"

@implementation NSDictionary (FRP)

- (NSDictionary *)aps_map:(id (^)(id key, id obj))map {
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        results[key] = map(key, obj);
    }];
    
    return [results copy];
}

- (instancetype)aps_filter:(BOOL (^)(id key, id obj))filter {
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (filter(key, obj)) {
            results[key] = obj;
        }
    }];
    
    return [results copy];
}

- (NSDictionary *)aps_swapKeysAndValues {
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSParameterAssert([obj conformsToProtocol:@protocol(NSCopying)]);
        results[obj] = key;
    }];
    
    return [results copy];
}

@end
