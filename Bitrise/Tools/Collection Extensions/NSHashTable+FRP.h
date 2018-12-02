//
//  NSHashTable+FRP.h
//  AppSpectorSDK
//
//  Created by Deszip on 25/07/2017.
//  Copyright © 2017 Techery. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSHashTable<ObjectType> (FRP)

- (NSArray *)aps_map:(id (^)(ObjectType obj))map;
- (NSArray<ObjectType> *)aps_filter:(BOOL (^)(ObjectType obj))filter;

@end

