//
//  NSArray+FRP.m
//  FileProcessor
//
//  Created by Deszip on 16/05/2019.
//  Copyright © 2019 FileProcessing Inc. All rights reserved.
//

#import "NSArray+FRP.h"

@implementation NSArray (FRP)

- (id)fp_map:(id (^)(id obj))map {
    NSMutableArray *results = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [results addObject:map(obj)];
    }];
    
    return [results copy];
}

- (instancetype)fp_filter:(BOOL (^)(id))filter {
    NSMutableArray *results = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (filter(obj)) {
            [results addObject:obj];
        }
    }];
    
    return [results copy];
}


@end
