//
//  BRAccountsMenuController.m
//  BitBot
//
//  Created by Deszip on 29/12/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRAccountsMenuController.h"

#import "BRMacro.h"
#import "BRAccount+CoreDataClass.h"
#import "BRApp+CoreDataClass.h"
#import "BRRemoveAccountCommand.h"

@interface BRAccountsMenuController () <NSMenuItemValidation, NSMenuDelegate>

@property (strong, nonatomic) BRBitriseAPI *api;
@property (strong, nonatomic) BRStorage *storage;

@property (weak, nonatomic) NSMenu *menu;
@property (weak, nonatomic) NSOutlineView *outlineView;
@property (strong, nonatomic) NSMenuItem *deleteItem;
@property (strong, nonatomic) NSMenuItem *keyItem;

@end

@implementation BRAccountsMenuController

- (instancetype)initWithAPI:(BRBitriseAPI *)api storage:(BRStorage *)storage {
    if (self = [super init]) {
        _api = api;
        _storage = storage;
    }
    
    return self;
}

- (void)bind:(NSMenu *)menu toOutline:(NSOutlineView *)outline {
    self.menu = menu;
    self.menu.delegate = self;
    self.outlineView = outline;
    self.outlineView.menu = self.menu;
    
    self.deleteItem = [[NSMenuItem alloc] initWithTitle:@"Delete account" action:@selector(deleteAccount) keyEquivalent:@""];
    [self.deleteItem setTarget:self];
    [self.menu insertItem:self.deleteItem atIndex:0];
}

- (void)deleteAccount {
    id selectedItem = [self.outlineView itemAtRow:[self.outlineView clickedRow]];
    if ([selectedItem isKindOfClass:[BRAccount class]]) {
        BR_SAFE_CALL(self.actionCallback, BRAppMenuActionRemoveAccount, [(BRAccount *)selectedItem slug]);
    }
}

#pragma mark - NSMenuItemValidation -

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    return YES;
}

#pragma mark - NSMenuDelegate -

- (void)menuWillOpen:(NSMenu *)menu {
    [self.menu removeAllItems];

    id selectedItem = [self.outlineView itemAtRow:[self.outlineView clickedRow]];
    if ([selectedItem isKindOfClass:[BRAccount class]]) {
        [self.menu insertItem:self.deleteItem atIndex:0];
    }
}

@end
