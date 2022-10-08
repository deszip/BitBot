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

NS_ASSUME_NONNULL_BEGIN

@interface BRFiltersMenuController : NSObject

@property (copy, nonatomic) void (^stateChageCallback)(BRBuildPredicate *);

- (instancetype)initWithPredicate:(BRBuildPredicate *)predicate;

- (void)bind:(NSMenu *)menu;

@end

NS_ASSUME_NONNULL_END
