//
//  BRCellBuilder.h
//  BitBot
//
//  Created by Deszip on 11/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

#import "BTRAccount+CoreDataClass.h"
#import "BRApp+CoreDataClass.h"
#import "BRBuild+CoreDataClass.h"
#import "BRAppCellView.h"
#import "BRBuildCellView.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRCellBuilder : NSObject

@property (copy, nonatomic) void (^menuPresenter)(NSButton *);

- (BRAppCellView *)appCell:(BRApp *)app forOutline:(NSOutlineView *)outline;
- (BRBuildCellView *)buildCell:(BRBuild *)build forOutline:(NSOutlineView *)outline;

@end

NS_ASSUME_NONNULL_END
