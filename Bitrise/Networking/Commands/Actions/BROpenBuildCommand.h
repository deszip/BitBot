//
//  BROpenBuildCommand.h
//  BitBot
//
//  Created by Deszip on 05/08/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "BRCommand.h"
#import "BREnvironment.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, BRBuildPageTab) {
    BRBuildPageTabLogs = 0,
    BRBuildPageTabArtefacts
};

@interface BROpenBuildCommand : BRCommand

- (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithBuildSlug:(NSString *)buildSlug tab:(BRBuildPageTab)tab environment:(BREnvironment * _Nullable)environment NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
