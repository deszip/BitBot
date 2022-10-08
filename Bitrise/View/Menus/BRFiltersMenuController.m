//
//  BRFiltersMenuController.m
//  BitBot
//
//  Created by Deszip on 06.10.2022.
//  Copyright © 2022 Bitrise. All rights reserved.
//

#import "BRFiltersMenuController.h"

typedef NS_ENUM(NSUInteger, BRFilterMenuItem) {
    BRFilterMenuItemSuccess = 0,
    BRFilterMenuItemFailed = 1,
    BRFilterMenuItemAborted = 2,
    BRFilterMenuItemInProgress = 3,
    BRFilterMenuItemOnHold = 4
};

@interface BRFiltersMenuController () <NSMenuItemValidation>

@property (strong, nonatomic) BRBuildPredicate *predicate;
@property (weak, nonatomic) NSMenu *menu;

@end

@implementation BRFiltersMenuController

- (instancetype)init {
    return [self initWithPredicate:[BRBuildPredicate allDisabled]];
}

- (instancetype)initWithPredicate:(BRBuildPredicate *)predicate {
    if (self = [super init]) {
        _predicate = predicate;
    }
    
    return self;
}

- (void)bind:(NSMenu *)menu {
    self.menu = menu;
    
    // Statuses
    NSMenuItem *successItem = [[NSMenuItem alloc] initWithTitle:@"Success" action:@selector(toggleSuccess) keyEquivalent:@""];
    [self.menu addItem:successItem];
    
    NSMenuItem *failedItem = [[NSMenuItem alloc] initWithTitle:@"Failed" action:@selector(toggleFailed) keyEquivalent:@""];
    [self.menu addItem:failedItem];
    
    NSMenuItem *abortedItem = [[NSMenuItem alloc] initWithTitle:@"Aborted" action:@selector(toggleAborted) keyEquivalent:@""];
    [self.menu addItem:abortedItem];
    
    NSMenuItem *inProgressItem = [[NSMenuItem alloc] initWithTitle:@"In Progress" action:@selector(toggleInProgress) keyEquivalent:@""];
    [self.menu addItem:inProgressItem];
    
    NSMenuItem *onHoldItem = [[NSMenuItem alloc] initWithTitle:@"On Hold" action:@selector(toggleOnHold) keyEquivalent:@""];
    [self.menu addItem:onHoldItem];
    
    [self.menu.itemArray enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
        [item setTag:idx];
        [item setTarget:self];
    }];
}

#pragma mark - Actions -

- (void)toggleSuccess {
    self.predicate.includeSuccess = !self.predicate.includeSuccess;
    self.stateChageCallback(self.predicate);
}

- (void)toggleFailed {
    self.predicate.includeFailed = !self.predicate.includeFailed;
    self.stateChageCallback(self.predicate);
}

- (void)toggleAborted {
    self.predicate.includeAborted = !self.predicate.includeAborted;
    self.stateChageCallback(self.predicate);
}

- (void)toggleInProgress {
    self.predicate.includeInProgress = !self.predicate.includeInProgress;
    self.stateChageCallback(self.predicate);
}

- (void)toggleOnHold {
    self.predicate.includeOnHold = !self.predicate.includeOnHold;
    self.stateChageCallback(self.predicate);
}

#pragma mark - NSMenuItemValidation -

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    // If all options disabled we dont want to display all checkmarks
    if (!self.predicate.hasEnabled) {
        [menuItem setState:NSControlStateValueOff];
        return YES;
    }
    
    if (menuItem.tag == BRFilterMenuItemSuccess) {
        [menuItem setState:self.predicate.includeSuccess ? NSControlStateValueOn : NSControlStateValueOff];
    }
    
    if (menuItem.tag == BRFilterMenuItemFailed) {
        [menuItem setState:self.predicate.includeFailed ? NSControlStateValueOn : NSControlStateValueOff];
    }
    
    if (menuItem.tag == BRFilterMenuItemAborted) {
        [menuItem setState:self.predicate.includeAborted ? NSControlStateValueOn : NSControlStateValueOff];
    }
    
    if (menuItem.tag == BRFilterMenuItemInProgress) {
        [menuItem setState:self.predicate.includeInProgress ? NSControlStateValueOn : NSControlStateValueOff];
    }
    
    if (menuItem.tag == BRFilterMenuItemOnHold) {
        [menuItem setState:self.predicate.includeOnHold ? NSControlStateValueOn : NSControlStateValueOff];
    }
    
    return YES;
}


@end
