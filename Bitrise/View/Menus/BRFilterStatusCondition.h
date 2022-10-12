//
//  BRFilterStatusCondition.h
//  BitBot
//
//  Created by Deszip on 12.10.2022.
//  Copyright © 2022 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, BRFilterStatusType) {
    BRFilterStatusTypeSuccess = 0,
    BRFilterStatusTypeFailed = 1,
    BRFilterStatusTypeAborted = 2,
    BRFilterStatusTypeOnHold = 3,
    BRFilterStatusTypeInProgress = 4
};


@interface BRFilterStatusCondition : NSObject

@property (assign, nonatomic, readonly) BRFilterStatusType statusType;
@property (retain, nonatomic, readonly) NSUUID *uuid;

- (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithType:(BRFilterStatusType)statusType NS_DESIGNATED_INITIALIZER;

- (NSPredicate *)predicate;

@end

NS_ASSUME_NONNULL_END
