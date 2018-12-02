//
//  NSDictionary+FRP.h
//  AppSpectorSDK
//
//  Created by Deszip on 19/09/2017.
//  Copyright © 2017 Techery. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary<KeyType, ObjectType> (FRP)

- (NSDictionary *)aps_map:(id (^)(KeyType key, ObjectType obj))map;
- (instancetype)aps_filter:(BOOL (^)(KeyType key, ObjectType obj))filter;

/// Value should support NSCopying in order to become key
- (NSDictionary *)aps_swapKeysAndValues;

@end
