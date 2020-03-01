//
//  NSHashTable+FRP.h
//  BitBot
//
//  Created by Deszip on 18/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSHashTable<ObjectType> (FRP)

- (NSArray *)aps_map:(id (^)(ObjectType obj))map;
- (NSArray<ObjectType> *)aps_filter:(BOOL (^)(ObjectType obj))filter;

@end

