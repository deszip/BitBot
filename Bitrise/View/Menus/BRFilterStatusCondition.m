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
        _statusType = statusType;
        _uuid = [NSUUID UUID];
    }
    
    return self;
}

- (NSPredicate *)predicate {
    switch (self.statusType) {
        case BRFilterStatusTypeSuccess: return [NSPredicate predicateWithFormat:@"status == 1"];
        case BRFilterStatusTypeFailed: return [NSPredicate predicateWithFormat:@"status == 2"];
        case BRFilterStatusTypeAborted: return [NSPredicate predicateWithFormat:@"status == 3 OR status == 4"];
        case BRFilterStatusTypeOnHold: return [NSPredicate predicateWithFormat:@"status == 0 AND onHold == YES"];
        case BRFilterStatusTypeInProgress: return [NSPredicate predicateWithFormat:@"status == 0 AND onHold == NO AND startTime != nil"];
    }
}

@end
