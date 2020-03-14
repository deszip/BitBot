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

typedef NS_ENUM(NSUInteger, BRAppsDataSourceNavigationAction) {
    BRAppsDataSourceNavigationActionUndefined = 0,
    BRAppsDataSourceNavigationActionOpenInBrowser
};

@interface BRAppsDataSource : NSObject <NSOutlineViewDataSource, NSOutlineViewDelegate>

@property (copy, nonatomic) void (^navigationCallback)(BRAppsDataSourceNavigationAction, BRBuild*);

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithContainer:(NSPersistentContainer *)container cellBuilder:(BRCellBuilder *)cellBuilder  NS_DESIGNATED_INITIALIZER;

- (void)bind:(NSOutlineView *)outlineView;
- (void)fetch;

@end

NS_ASSUME_NONNULL_END
