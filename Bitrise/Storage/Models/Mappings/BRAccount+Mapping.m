//
//  BRAccount+Mapping.m
//  Bitrise
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BRAccount+Mapping.h"

@implementation BRAccount (Mapping)

+ (EKManagedObjectMapping *)objectMapping {
    return [EKManagedObjectMapping mappingForEntityName:NSStringFromClass([self class]) withBlock:^(EKManagedObjectMapping *mapping) {
        [mapping mapKeyPath:@"username" toProperty:@"username"];
        [mapping mapKeyPath:@"email" toProperty:@"email"];
        [mapping mapKeyPath:@"unconfirmed_email" toProperty:@"emailUnconfirmed"];
        [mapping mapKeyPath:@"slug" toProperty:@"slug"];
        [mapping mapKeyPath:@"avatar_url" toProperty:@"avatarURL"];

        [mapping setPrimaryKey:@"slug"];
    }];
}

@end
