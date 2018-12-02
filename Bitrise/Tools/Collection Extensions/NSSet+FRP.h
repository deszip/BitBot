//
//  NSSet+FRP.h
//  AppSpectorSDK
//
//  Created by Deszip on 12/09/2017.
//  Copyright © 2017 Techery. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSSet<ObjectType> (FRP)

- (NSSet *)aps_map:(id (^)(ObjectType obj))map;
- (instancetype)aps_filter:(BOOL (^)(ObjectType obj))filter;

@end
