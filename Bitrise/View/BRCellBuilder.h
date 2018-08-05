//
//  BRCellBuilder.h
//  Bitrise
//
//  Created by Deszip on 11/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

#import "BRApp+CoreDataClass.h"
#import "BRBuild+CoreDataClass.h"
#import "BRAppCellView.h"
#import "BRBuildCellView.h"
#import "BRBuildStateInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRCellBuilder : NSObject

- (BRAppCellView *)appCell:(BRApp *)app forOutline:(NSOutlineView *)outline;
- (BRBuildCellView *)buildCell:(BRBuild *)build forOutline:(NSOutlineView *)outline;

@end

NS_ASSUME_NONNULL_END
