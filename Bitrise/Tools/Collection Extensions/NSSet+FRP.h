//
//  NSSet+FRP.h
//  BitBot
//
//  Created by Deszip on 18/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSSet<ObjectType> (FRP)

- (NSSet *)aps_map:(id (^)(ObjectType obj))map;
- (instancetype)aps_filter:(BOOL (^)(ObjectType obj))filter;

@end
