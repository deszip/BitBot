//
//  BRSettingsMenuController.h
//  BitBot
//
//  Created by Deszip on 22/12/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

#import "BREnvironment.h"
#import "BRLauncher.h"
#import "BRNotificationDispatcher.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, BRSettingsMenuNavigationAction) {
    BRSettingsMenuNavigationActionUndefined = 0,
    BRSettingsMenuNavigationActionAbout,
    BRSettingsMenuNavigationActionAccounts
};

@interface BRSettingsMenuController : NSObject

@property (copy, nonatomic) void (^navigationCallback)(BRSettingsMenuNavigationAction);

- (instancetype)initWithEnvironment:(BREnvironment *)environment
                        appLauncher:(BRLauncher *)appLauncher
            notificationsDispatcher:(BRNotificationDispatcher *)notificationsDispatcher;
- (void)bind:(NSMenu *)menu;

@end

NS_ASSUME_NONNULL_END
