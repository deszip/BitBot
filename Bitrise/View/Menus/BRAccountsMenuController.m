//
//  BRAccountsMenuController.m
//  Bitrise
//
//  Created by Deszip on 29/12/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BRAccountsMenuController.h"

#import "BRAccount+CoreDataClass.h"
#import "BRApp+CoreDataClass.h"

@interface BRAccountsMenuController () <NSMenuItemValidation, NSMenuDelegate>

@property (weak, nonatomic) NSMenu *menu;
@property (weak, nonatomic) NSOutlineView *outlineView;
@property (strong, nonatomic) NSMenuItem *deleteItem;
@property (strong, nonatomic) NSMenuItem *keyItem;

@end

@implementation BRAccountsMenuController

- (void)bind:(NSMenu *)menu toOutline:(NSOutlineView *)outline {
    self.menu = menu;
    self.menu.delegate = self;
    self.outlineView = outline;
    self.outlineView.menu = self.menu;
    
    self.deleteItem = [[NSMenuItem alloc] initWithTitle:@"Delete account" action:@selector(deleteAccount) keyEquivalent:@""];
    [self.deleteItem setTarget:self];
    self.keyItem = [[NSMenuItem alloc] initWithTitle:@"Add build key..." action:@selector(addBuildKey) keyEquivalent:@""];
    [self.keyItem setTarget:self];
}

- (void)deleteAccount {
    id selectedItem = [self.outlineView itemAtRow:[self.outlineView clickedRow]];
    if ([selectedItem isKindOfClass:[BRAccount class]]) {
        NSLog(@"Deleting account: %@", selectedItem);
    }
}

- (void)addBuildKey {
    id selectedItem = [self.outlineView itemAtRow:[self.outlineView clickedRow]];
    if ([selectedItem isKindOfClass:[BRApp class]]) {
        NSLog(@"Add key for: %@", selectedItem);
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
    if ([selectedItem isKindOfClass:[BRApp class]]) {
        [self.menu insertItem:self.keyItem atIndex:0];
    }
}

@end
