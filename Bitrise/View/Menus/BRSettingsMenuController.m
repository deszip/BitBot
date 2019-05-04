//
//  BRSettingsMenuController.m
//  BitBot
//
//  Created by Deszip on 22/12/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRSettingsMenuController.h"

#import "BRAnalytics.h"
#import "BRMacro.h"

static const NSUInteger kMenuItemsCount = 7;
typedef NS_ENUM(NSUInteger, BRSettingsMenuItem) {
    BRSettingsMenuItemAbout = 0,
    BRSettingsMenuItemAccounts = 2,
    BRSettingsMenuItemAutorun = 3,
    BRSettingsMenuItemNotifications = 4,
    BRSettingsMenuItemQuit = 6
};

@interface BRSettingsMenuController () <NSMenuItemValidation>

@property (strong, nonatomic) BREnvironment *environment;
@property (weak, nonatomic) NSMenu *menu;

@end

@implementation BRSettingsMenuController

- (instancetype)initWithEnvironment:(BREnvironment *)environment {
    if (self = [super init]) {
        _environment = environment;
    }
    
    return self;
}

- (void)bind:(NSMenu *)menu {
    self.menu = menu;
    
    if (self.menu.itemArray.count == kMenuItemsCount) {
        [self.menu.itemArray enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
            [item setTag:idx];
            [item setTarget:self];
        }];
        
        [self.menu.itemArray[BRSettingsMenuItemAbout]           setAction:@selector(showAbout)];
        [self.menu.itemArray[BRSettingsMenuItemAccounts]        setAction:@selector(showAccounts)];
        [self.menu.itemArray[BRSettingsMenuItemAutorun]         setAction:@selector(toggleAutorun)];
        [self.menu.itemArray[BRSettingsMenuItemNotifications]   setAction:@selector(toggleNotifications)];
        [self.menu.itemArray[BRSettingsMenuItemQuit]            setAction:@selector(quitApp)];
    }
}

#pragma mark - Actions -

- (void)showAbout {
    [[BRAnalytics analytics] trackAboutOpen];
    BR_SAFE_CALL(self.navigationCallback, BRSettingsMenuNavigationActionAbout);
}

- (void)showAccounts {
    [[BRAnalytics analytics] trackAccountsOpen];
    BR_SAFE_CALL(self.navigationCallback, BRSettingsMenuNavigationActionAccounts);
}

- (void)toggleAutorun {
    [[BRAnalytics analytics] trackAutorunToggle];
    [self.environment toggleAutolaunch];
}

- (void)toggleNotifications {
    [[BRAnalytics analytics] trackNotificationsToggle];
    [self.environment toggleNotifications];
}

- (void)quitApp {
    [[BRAnalytics analytics] trackQuitApp];
    [self.environment quitApp];
}

#pragma mark - NSMenuItemValidation -

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    if (menuItem.tag == BRSettingsMenuItemAutorun) {
        [menuItem setState:[self.environment autolaunchEnabled] ? NSControlStateValueOn : NSControlStateValueOff];
    }
    
    if (menuItem.tag == BRSettingsMenuItemNotifications) {
        [menuItem setState:[self.environment notificationsEnabled] ? NSControlStateValueOn : NSControlStateValueOff];
    }
    
    return YES;
}

@end
