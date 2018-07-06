//
//  BRAppsDataSource.h
//  Bitrise
//
//  Created by Deszip on 04/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRAppsDataSource : NSObject <NSOutlineViewDataSource, NSOutlineViewDelegate>

@property (assign, nonatomic, readonly) BOOL treeView;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithContainer:(NSPersistentContainer *)container outline:(NSOutlineView *)outline NS_DESIGNATED_INITIALIZER;

- (void)enableTreeView:(BOOL)treeView;

- (void)fetch;
- (void)buildStubs;

@end

NS_ASSUME_NONNULL_END
