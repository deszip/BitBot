//
//  BRAppsDataSource.h
//  BitBot
//
//  Created by Deszip on 04/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "BRCellBuilder.h"
#import "BRBuildPredicate.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, BRBuildsState) {
    BRBuildsStateEmpty = 0,
    BRBuildsStateHasData
};

typedef void(^BRBuildsStateCallback)(BRBuildsState state);

@interface BRAppsDataSource : NSObject

@property (assign, nonatomic, readonly) BRBuildsState state;

- (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithContainer:(NSPersistentContainer *)container cellBuilder:(BRCellBuilder *)cellBuilder  NS_DESIGNATED_INITIALIZER;

- (void)bind:(NSOutlineView *)outlineView;
- (void)fetch;

- (void)applyPredicate:(BRBuildPredicate *)predicate;

- (void)setStateCallback:(BRBuildsStateCallback)callback;

@end

NS_ASSUME_NONNULL_END
