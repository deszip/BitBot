//
//  BRBuildPredicate.h
//  BitBot
//
//  Created by Deszip on 06.10.2022.
//  Copyright © 2022 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BRFilterStatusCondition.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRBuildPredicate : NSObject

- (BOOL)hasConditions;

- (void)toggleCondition:(BRFilterStatusCondition *)condition;
- (BOOL)hasCondition:(BRFilterStatusCondition *)condition;

- (NSPredicate *)predicate;
    
@end

NS_ASSUME_NONNULL_END
