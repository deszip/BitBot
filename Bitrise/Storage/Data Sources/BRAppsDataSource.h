//
//  BRAppsDataSource.h
//  BitBot
//
//  Created by Deszip on 04/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "BRCellBuilder.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, BRAppsDataSourceState) {
    BRAppsDataSourceStateEmpty = 0,
    BRAppsDataSourceStateHasData
};

@interface BRAppsDataSource : NSObject <NSOutlineViewDataSource, NSOutlineViewDelegate>

@property (assign, nonatomic, readonly) BRAppsDataSourceState state;
@property (copy, nonatomic) void (^stateCallback)(BRAppsDataSourceState);

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithContainer:(NSPersistentContainer *)container cellBuilder:(BRCellBuilder *)cellBuilder  NS_DESIGNATED_INITIALIZER;

- (void)bind:(NSOutlineView *)outlineView;
- (void)fetch;

@end

NS_ASSUME_NONNULL_END
