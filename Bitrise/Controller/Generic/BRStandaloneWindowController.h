//
//  BRStandaloneWindowController.h
//  BitBot
//
//  Created by Deszip on 21.11.2021.
//  Copyright © 2021 Bitrise. All rights reserved.
//

#import "BRWindowController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, BRStandaloneTab) {
    BRStandaloneTabInfo = 0,
    BRStandaloneTabSchedule = 1,
    BRStandaloneTabStats = 2,
    BRStandaloneTabSettings = 3
};

extern NSNotificationName kStandaloneTabSelectedNotification;

@interface BRStandaloneWindowController : BRWindowController

@property (strong, nonatomic, readonly) id <BREnvironmentProvider> dependencyContainer;

@end

NS_ASSUME_NONNULL_END
