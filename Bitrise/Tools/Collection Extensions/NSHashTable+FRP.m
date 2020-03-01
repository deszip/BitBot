//
//  NSHashTable+FRP.m
//  BitBot
//
//  Created by Deszip on 18/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "NSHashTable+FRP.h"

@implementation NSHashTable (FRP)

- (NSArray *)aps_map:(id (^)(id obj))map {
    NSMutableArray *results = [NSMutableArray array];
    id nextObject;
    NSEnumerator *enumerator = self.objectEnumerator;
    while (nextObject = [enumerator nextObject]) {
        [results addObject:map(nextObject)];
    }
    
    return [results copy];
}

- (NSArray *)aps_filter:(BOOL (^)(id))filter {
    NSMutableArray *results = [NSMutableArray array];
    id nextObject;
    NSEnumerator *enumerator = self.objectEnumerator;
    while (nextObject = [enumerator nextObject]) {
        if (filter(nextObject)) {
            [results addObject:nextObject];
        }
    }
    
    return [results copy];
}

@end
