//
//  BRFilterStatusCondition.m
//  BitBot
//
//  Created by Deszip on 12.10.2022.
//  Copyright © 2022 Bitrise. All rights reserved.
//

#import "BRFilterStatusCondition.h"

@implementation BRFilterStatusCondition

- (instancetype)initWithType:(BRFilterStatusType)statusType {
    if (self = [super init]) {
        _uuid = [NSUUID UUID];
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
    if (self = [super init]) {
        _uuid = [NSUUID UUID];
        _predicate = [NSPredicate predicateWithFormat:@"app.slug == %@", appSlug];
    }
    
    return self;
}

@end
