//
//  BRFiltersMenuController.h
//  BitBot
//
//  Created by Deszip on 06.10.2022.
//  Copyright © 2022 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

#import "BRBuildPredicate.h"
#import "BRFilterItemProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRFiltersMenuController : NSObject

@property (copy, nonatomic) void (^stateChageCallback)(BRBuildPredicate *);

- (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithPredicate:(BRBuildPredicate *)predicate itemProvider:(BRFilterItemProvider *)itemProvider NS_DESIGNATED_INITIALIZER;

- (void)bind:(NSMenu *)menu;

@end

NS_ASSUME_NONNULL_END
