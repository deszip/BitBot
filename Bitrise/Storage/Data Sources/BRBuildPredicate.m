//
//  BRBuildPredicate.m
//  BitBot
//
//  Created by Deszip on 06.10.2022.
//  Copyright © 2022 Bitrise. All rights reserved.
//

#import "BRBuildPredicate.h"

@implementation BRBuildPredicate

- (instancetype)init {
    if (self = [super init]) {
        _includeFailed = YES;
        _includeAborted = YES;
        _includeSuccess = YES;
        _includeOnHold = YES;
        _includeInProgress = YES;
    }
    
    return self;
}

+ (instancetype)allEnabled {
    return [BRBuildPredicate new];
}

+ (instancetype)allDisabled {
    BRBuildPredicate *predicate = [BRBuildPredicate new];
    predicate.includeFailed = NO;
    predicate.includeAborted = NO;
    predicate.includeSuccess = NO;
    predicate.includeOnHold = NO;
    predicate.includeInProgress = NO;
    
    return predicate;
}

- (BOOL)hasEnabled {
    return
    self.includeFailed ||
    self.includeAborted ||
    self.includeSuccess ||
    self.includeOnHold ||
    self.includeInProgress;
}

- (NSPredicate *)predicate {
    NSMutableArray <NSPredicate *> *subPredicates = [NSMutableArray array];
    
    if (self.includeFailed) {
        [subPredicates addObject:[NSPredicate predicateWithFormat:@"status == 2"]];
    }
    
    if (self.includeAborted) {
        [subPredicates addObject:[NSPredicate predicateWithFormat:@"status == 3 OR status == 4"]];
    }
    
    if (self.includeSuccess) {
        [subPredicates addObject:[NSPredicate predicateWithFormat:@"status == 1"]];
    }
    
    if (self.includeOnHold) {
        [subPredicates addObject:[NSPredicate predicateWithFormat:@"status == 0 AND onHold == YES"]];
    }
    
    if (self.includeInProgress) {
        [subPredicates addObject:[NSPredicate predicateWithFormat:@"status == 0 AND onHold == NO AND startTime != nil"]];
    }
    
    // Predicate with empty subpredicates fails FRC fetch
    if (subPredicates.count) {
        return [[NSCompoundPredicate alloc] initWithType:NSOrPredicateType subpredicates:subPredicates];
    }
    
    return nil;
}

@end
