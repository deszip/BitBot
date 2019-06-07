//
//  NSDictionary+FRP.h
//  BitBot
//
//  Created by Deszip on 18/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary<KeyType, ObjectType> (FRP)

- (NSDictionary *)aps_map:(id (^)(KeyType key, ObjectType obj))map;
- (instancetype)aps_filter:(BOOL (^)(KeyType key, ObjectType obj))filter;

/// Value should support NSCopying in order to become key
- (NSDictionary *)aps_swapKeysAndValues;

@end
