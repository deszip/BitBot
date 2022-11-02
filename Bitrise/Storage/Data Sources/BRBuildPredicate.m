//
//  BRBuildPredicate.m
//  BitBot
//
//  Created by Deszip on 06.10.2022.
//  Copyright © 2022 Bitrise. All rights reserved.
//

#import "BRBuildPredicate.h"

@interface BRBuildPredicate ()

@property (strong, nonatomic) NSMutableDictionary <NSNumber *, NSMutableDictionary <NSUUID *, BRFilterCondition *> *> *conditions;

@end

@implementation BRBuildPredicate

- (instancetype)init {
    if (self = [super init]) {
        _conditions = [NSMutableDictionary new];
    }
    
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.conditions forKey:@"conditions"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        NSSet *classes = [NSSet setWithObjects:
                          [NSMutableDictionary class],
                          [NSUUID class],
                          [NSComparisonPredicate class],
                          [NSCompoundPredicate class],
                          [NSNumber class],
                          [BRFilterCondition class], nil];
        self.conditions = [decoder decodeObjectOfClasses:classes forKey:@"conditions"];
    }
    
    return self;
}

- (void)clear {
    [self.conditions removeAllObjects];
}

- (BOOL)hasConditions {
    return self.conditions.count > 0;
}

- (void)toggleCondition:(BRFilterCondition *)condition {
    NSMutableDictionary *conditionGroup = self.conditions[@(condition.group)];
    if (!conditionGroup) {
        conditionGroup = [NSMutableDictionary new];
    }
    if ([conditionGroup.allKeys containsObject:condition.uuid]) {
        [conditionGroup removeObjectForKey:condition.uuid];
    } else {
        conditionGroup[condition.uuid] = condition;
    }
    
    if (conditionGroup.count == 0) {
        [self.conditions removeObjectForKey:@(condition.group)];
    } else {
        self.conditions[@(condition.group)] = conditionGroup;
    }
}

- (BOOL)hasCondition:(BRFilterCondition *)condition {
    NSMutableDictionary *conditionGroup = self.conditions[@(condition.group)];
    if (!conditionGroup) {
        return NO;
    }
    
    return [[conditionGroup keysOfEntriesPassingTest:^BOOL(NSUUID *key, BRFilterCondition *nextCondition, BOOL *stop) {
        return  [condition.predicate isEqualTo:nextCondition.predicate];
    }] count] > 0;
}

- (NSPredicate *)predicate {
    __block NSMutableArray <NSPredicate *> *subPredicates = [NSMutableArray array];
    
    [self.conditions enumerateKeysAndObjectsUsingBlock:^(NSNumber *group, NSMutableDictionary<NSUUID *,BRFilterCondition *> *conditions, BOOL *stop) {
        __block NSMutableArray <NSPredicate *> *groupPredicates = [NSMutableArray array];
        [conditions.allValues enumerateObjectsUsingBlock:^(BRFilterCondition *condition, NSUInteger idx, BOOL *stop) {
            [groupPredicates addObject:[condition predicate]];
        }];
        if (groupPredicates.count > 0) {
            NSPredicate *groupPredicate = [[NSCompoundPredicate alloc] initWithType:NSOrPredicateType subpredicates:groupPredicates];
            [subPredicates addObject:groupPredicate];
        }
    }];
    
    // Predicate with empty subpredicates fails FRC fetch
    if (subPredicates.count) {
        return [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:subPredicates];
    }
    
    return nil;
}

@end
