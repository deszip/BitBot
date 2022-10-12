//
//  BRBuildPredicate.m
//  BitBot
//
//  Created by Deszip on 06.10.2022.
//  Copyright © 2022 Bitrise. All rights reserved.
//

#import "BRBuildPredicate.h"

@interface BRBuildPredicate ()

@property (strong, nonatomic) NSMutableDictionary <NSUUID *, BRFilterStatusCondition *> *conditions;

@end

@implementation BRBuildPredicate

- (instancetype)init {
    if (self = [super init]) {
        _conditions = [NSMutableDictionary new];
    }
    
    return self;
}

- (BOOL)hasConditions {
    return self.conditions.count > 0;
}

- (void)toggleCondition:(BRFilterStatusCondition *)condition {
    if ([self.conditions.allKeys containsObject:condition.uuid]) {
        [self.conditions removeObjectForKey:condition.uuid];
    } else {
        self.conditions[condition.uuid] = condition;
    }
}

- (BOOL)hasCondition:(BRFilterStatusCondition *)condition {
    return [self.conditions.allKeys containsObject:condition.uuid];
}

- (NSPredicate *)predicate {
    NSMutableArray <NSPredicate *> *subPredicates = [NSMutableArray array];
    
    [self.conditions.allValues enumerateObjectsUsingBlock:^(BRFilterStatusCondition *condition, NSUInteger idx, BOOL *stop) {
        [subPredicates addObject:[condition predicate]];
    }];
    
    // Predicate with empty subpredicates fails FRC fetch
    if (subPredicates.count) {
        return [[NSCompoundPredicate alloc] initWithType:NSOrPredicateType subpredicates:subPredicates];
    }
    
    return nil;
}

@end
