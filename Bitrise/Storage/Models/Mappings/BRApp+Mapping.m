//
//  BRApp+Mapping.m
//  Bitrise
//
//  Created by Deszip on 10/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BRApp+Mapping.h"

@implementation BRApp (Mapping)

+ (EKManagedObjectMapping *)objectMapping {
    return [EKManagedObjectMapping mappingForEntityName:NSStringFromClass([self class]) withBlock:^(EKManagedObjectMapping *mapping) {
        [mapping mapKeyPath:@"slug" toProperty:@"slug"];
        [mapping mapKeyPath:@"title" toProperty:@"title"];
        [mapping mapKeyPath:@"project_type" toProperty:@"projectType"];
        [mapping mapKeyPath:@"provider" toProperty:@"provider"];
        [mapping mapKeyPath:@"slug" toProperty:@"slug"];
        [mapping mapKeyPath:@"repo_owner" toProperty:@"repoOwner"];
        [mapping mapKeyPath:@"repo_url" toProperty:@"repoURL"];
        [mapping mapKeyPath:@"repo_slug" toProperty:@"repoSlug"];
        [mapping mapKeyPath:@"is_disabled" toProperty:@"disabled"];
        [mapping mapKeyPath:@"status" toProperty:@"status"];
        [mapping mapKeyPath:@"is_public" toProperty:@"public"];
        [mapping mapKeyPath:@"avatar_url" toProperty:@"avatarURL"];
        [mapping mapKeyPath:@"owner.account_type" toProperty:@"ownerAccountType"];
        [mapping mapKeyPath:@"owner.name" toProperty:@"ownerName"];
        [mapping mapKeyPath:@"owner.slug" toProperty:@"ownerSlug"];
        
        [mapping setPrimaryKey:@"slug"];
    }];
}


@end
