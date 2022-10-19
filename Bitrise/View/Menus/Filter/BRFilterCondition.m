//
//  BRFilterCondition.m
//  BitBot
//
//  Created by Deszip on 12.10.2022.
//  Copyright © 2022 Bitrise. All rights reserved.
//

#import "BRFilterCondition.h"

@implementation BRFilterCondition

- (instancetype)init {
    if (self = [super init]) {
        _uuid = [NSUUID UUID];
    }
    
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.uuid forKey:@"uuid"];
    [encoder encodeObject:@(self.group) forKey:@"group"];
    [encoder encodeObject:self.predicate forKey:@"predicate"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        _uuid = [decoder decodeObjectForKey:@"uuid"];
        _group = [[decoder decodeObjectForKey:@"group"] integerValue];
        _predicate = [decoder decodeObjectForKey:@"predicate"];
    }
    
    return self;
}

- (instancetype)initWithBuildStatus:(BRFilterStatusType)statusType {
    if (self = [self init]) {
        _group = BRFilterConditionGroupStatus;
        switch (statusType) {
            case BRFilterStatusTypeSuccess:
                _predicate = [NSPredicate predicateWithFormat:@"status == 1"];
                break;
            case BRFilterStatusTypeFailed:
                _predicate = [NSPredicate predicateWithFormat:@"status == 2"];
                break;
            case BRFilterStatusTypeAborted:
                _predicate = [NSPredicate predicateWithFormat:@"status == 3 OR status == 4"];
                break;
            case BRFilterStatusTypeOnHold:
                _predicate = [NSPredicate predicateWithFormat:@"status == 0 AND onHold == YES"];
                break;
            case BRFilterStatusTypeInProgress:
                _predicate = [NSPredicate predicateWithFormat:@"status == 0 AND onHold == NO AND startTime != nil"];
                break;
        }
    }
    
    return self;
}

- (instancetype)initWithAppSlug:(NSString *)appSlug {
    if (self = [self init]) {
        _group = BRFilterConditionGroupApp;
        _predicate = [NSPredicate predicateWithFormat:@"app.slug == %@", appSlug];
    }
    
    return self;
}

- (instancetype)initWithAccountSlug:(NSString *)accountSlug {
    if (self = [self init]) {
        _group = BRFilterConditionGroupAccount;
        _predicate = [NSPredicate predicateWithFormat:@"app.account.slug == %@", accountSlug];
    }
    
    return self;
}

@end
