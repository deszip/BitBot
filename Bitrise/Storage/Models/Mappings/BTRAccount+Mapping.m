//
//  BRAccount+Mapping.m
//  BitBot
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BTRAccount+Mapping.h"

@implementation BTRAccount (Mapping)

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
