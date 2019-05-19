//
//  NSArray+FRP.h
//  FileProcessor
//
//  Created by Deszip on 16/05/2019.
//  Copyright © 2019 FileProcessing Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray<ObjectType> (FRP)

- (NSArray *)fp_map:(id (^)(ObjectType obj))map;
- (instancetype)fp_filter:(BOOL (^)(ObjectType obj))filter;

@end
