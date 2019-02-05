//
//  BRBuildMenuController.h
//  BitBot
//
//  Created by Deszip on 25/12/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

#import "BRBitriseAPI.h"
#import "BRSyncEngine.h"
#import "BRLogObserver.h"
#import "BREnvironment.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, BRBuildMenuAction) {
    BRBuildMenuActionUndefined = 0,
    BRBuildMenuActionShowLog
};

@interface BRBuildMenuController : NSObject

@property (copy, nonatomic) void (^actionCallback)(BRBuildMenuAction action, NSString *buildSlug);

- (instancetype)initWithAPI:(BRBitriseAPI *)api
                 syncEngine:(BRSyncEngine *)syncEngine
                logObserver:(BRLogObserver *)logObserver
                environment:(BREnvironment *)environment;
- (void)bind:(NSMenu *)menu toOutline:(NSOutlineView *)outline;

@end

NS_ASSUME_NONNULL_END
