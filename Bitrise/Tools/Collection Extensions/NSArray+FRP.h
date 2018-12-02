//
//  NSArray+FRP.h
//  AppSpectorSDK
//
//  Created by Deszip on 25/07/2017.
//  Copyright © 2017 Techery. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray<ObjectType> (FRP)

- (NSArray *)aps_map:(id (^)(ObjectType obj))map;
- (instancetype)aps_filter:(BOOL (^)(ObjectType obj))filter;

@end
