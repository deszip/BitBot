//
//  BRFilterCondition.h
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

typedef NS_ENUM(NSUInteger, BRFilterConditionGroup) {
    BRFilterConditionGroupStatus = 0,
    BRFilterConditionGroupApp = 1,
    BRFilterConditionGroupAccount = 2
};

@interface BRFilterCondition : NSObject

@property (strong, nonatomic, readonly) NSUUID *uuid;
@property (assign, nonatomic, readonly) BRFilterConditionGroup group;
@property (strong, nonatomic, readonly) NSPredicate *predicate;

- (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithBuildStatus:(BRFilterStatusType)statusType;
- (instancetype)initWithAppSlug:(NSString *)appSlug;
- (instancetype)initWithAccountSlug:(NSString *)accountSlug;

@end

NS_ASSUME_NONNULL_END
