//
//  BRBuildPredicate.h
//  BitBot
//
//  Created by Deszip on 06.10.2022.
//  Copyright © 2022 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BRFilterCondition.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRBuildPredicate : NSObject <NSSecureCoding>

- (void)clear;
- (BOOL)hasConditions;

- (void)toggleCondition:(BRFilterCondition *)condition;
- (BOOL)hasCondition:(BRFilterCondition *)condition;

- (NSPredicate *)predicate;
    
@end

NS_ASSUME_NONNULL_END
