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
        [mapping mapKeyPath:@"timestamp" toProperty:@"timestamp" withValueBlock:^id(NSString *key, id value, NSManagedObjectContext *context) {
            if (value && value != [NSNull null]) {
                return [NSDate dateWithTimeIntervalSince1970:[value doubleValue]];
            }
            
            return nil;
        }];
        
        [mapping setPrimaryKey:@"expiringRawLogURL"];
    }];
}


@end
