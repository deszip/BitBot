//
//  BRSettingsMenuController.m
//  Bitrise
//
//  Created by Deszip on 22/12/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BRSettingsMenuController.h"

#import "BRMacro.h"

typedef NS_ENUM(NSUInteger, BRSettingsMenuItem) {
    BRSettingsMenuItemAbout = 0,
    BRSettingsMenuItemAccounts,
    BRSettingsMenuItemAutorun,
    BRSettingsMenuItemQuit
};

@interface BRSettingsMenuController () <NSMenuDelegate>

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
    [self.menu setDelegate:self];
    
    if (self.menu.itemArray.count == 4) {
        [self.menu.itemArray enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
            [item setTag:idx];
        }];
        
        [self.menu.itemArray[BRSettingsMenuItemAbout]       setAction:@selector(showAbout)];
        [self.menu.itemArray[BRSettingsMenuItemAccounts]    setAction:@selector(showAccounts)];
        [self.menu.itemArray[BRSettingsMenuItemAutorun]     setAction:@selector(toggleAutorun)];
        [self.menu.itemArray[BRSettingsMenuItemQuit]        setAction:@selector(quitApp)];
    }
}

#pragma mark - Actions -

- (void)showAbout {
    BR_SAFE_CALL(self.navigationCallback, BRSettingsMenuNavigationActionAbout);
}

- (void)showAccounts {
    BR_SAFE_CALL(self.navigationCallback, BRSettingsMenuNavigationActionAccounts);
}

- (void)toggleAutorun {
    [self.environment toggleAutolaunch];
}

- (void)quitApp {
    [self.environment quitApp];
}

#pragma mark - NSMenuDelegate -

- (void)menuWillOpen:(NSMenu *)menu {
    //...
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    if (menuItem.tag == BRSettingsMenuItemAutorun) {
        [menuItem setState:[self.environment autolaunchEnabled] ? NSControlStateValueOn : NSControlStateValueOff];
    }
    
    return YES;
}

@end
