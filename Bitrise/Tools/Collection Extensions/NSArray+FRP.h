//
//  NSArray+FRP.h
//  BitBot
//
//  Created by Deszip on 18/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray<ObjectType> (FRP)

- (NSArray *)aps_map:(id (^)(ObjectType obj))map;
- (instancetype)aps_filter:(BOOL (^)(ObjectType obj))filter;

@end
