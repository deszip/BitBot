//
//  BRAccountsDataSource.h
//  Bitrise
//
//  Created by Deszip on 06/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRAccountsDataSource : NSObject <NSOutlineViewDataSource, NSOutlineViewDelegate>

- (instancetype)initWithContainer:(NSPersistentContainer *)container;

- (void)bind:(NSOutlineView *)outlineView;
- (void)fetch;

@end

NS_ASSUME_NONNULL_END
