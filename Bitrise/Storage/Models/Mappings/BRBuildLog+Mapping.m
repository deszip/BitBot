//
//  BRBuildLog+Mapping.m
//  Bitrise
//
//  Created by Deszip on 02/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRBuildLog+Mapping.h"

#import "BRLogChunk+CoreDataClass.h"

@implementation BRBuildLog (Mapping)

+ (EKManagedObjectMapping *)objectMapping {
    return [EKManagedObjectMapping mappingForEntityName:NSStringFromClass([self class]) withBlock:^(EKManagedObjectMapping *mapping) {
        [mapping mapKeyPath:@"is_archived" toProperty:@"archived"];
        [mapping mapKeyPath:@"generated_log_chunks_num" toProperty:@"chunksCount"];
        [mapping mapKeyPath:@"expiring_raw_log_url" toProperty:@"expiringRawLogURL"];
        [mapping mapKeyPath:@"timestamp" toProperty:@"timestamp"];
        
        [mapping hasMany:[BRLogChunk class] forKeyPath:@"log_chunks" forProperty:@"chunks"];
        
        [mapping setPrimaryKey:@"expiringRawLogURL"];
    }];
}


@end
