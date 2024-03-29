//
//  BREmptyView.h
//  Bitrise
//
//  Created by Deszip on 20.06.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, BREmptyViewType) {
    BREmptyViewTypeNoAccounts = 0,
    BREmptyViewTypeNoData = 1
};

@interface BREmptyView : NSView

@property (assign, nonatomic) BREmptyViewType viewType;
@property (copy, nonatomic) void (^callback)(void);

@end

NS_ASSUME_NONNULL_END
