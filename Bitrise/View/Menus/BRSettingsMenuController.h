//
//  BRSettingsMenuController.h
//  Bitrise
//
//  Created by Deszip on 22/12/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

#import "BREnvironment.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, BRSettingsMenuNavigationAction) {
    BRSettingsMenuNavigationActionUndefined = 0,
    BRSettingsMenuNavigationActionAbout,
    BRSettingsMenuNavigationActionAccounts
};

@interface BRSettingsMenuController : NSObject

@property (copy, nonatomic) void (^navigationCallback)(BRSettingsMenuNavigationAction);

- (instancetype)initWithEnvironment:(BREnvironment *)environment;
- (void)bind:(NSMenu *)menu;

@end

NS_ASSUME_NONNULL_END
