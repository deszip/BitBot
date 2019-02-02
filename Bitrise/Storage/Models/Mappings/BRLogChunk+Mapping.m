//
//  BRLogChunk+Mapping.m
//  Bitrise
//
//  Created by Deszip on 02/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRLogChunk+Mapping.h"

@implementation BRLogChunk (Mapping)

+ (EKManagedObjectMapping *)objectMapping {
    return [EKManagedObjectMapping mappingForEntityName:NSStringFromClass([self class]) withBlock:^(EKManagedObjectMapping *mapping) {
        [mapping mapKeyPath:@"position" toProperty:@"position"];
        [mapping mapKeyPath:@"chunk" toProperty:@"text"];
        
        [mapping setPrimaryKey:@"position"];
    }];
}

@end
