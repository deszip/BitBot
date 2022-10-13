//
//  BRFiltersMenuController.m
//  BitBot
//
//  Created by Deszip on 06.10.2022.
//  Copyright © 2022 Bitrise. All rights reserved.
//

#import "BRFiltersMenuController.h"

#import "BRFilterCondition.h"

typedef NS_ENUM(NSUInteger, BRFilterMenuItem) {
    BRFilterMenuItemSuccess = 0,
    BRFilterMenuItemFailed = 1,
    BRFilterMenuItemAborted = 2,
    BRFilterMenuItemOnHold = 3,
    BRFilterMenuItemInProgress = 4
};

@interface BRFiltersMenuController () <NSMenuItemValidation>

@property (strong, nonatomic) BRBuildPredicate *predicate;
@property (strong, nonatomic) BRFilterItemProvider *itemProvider;
@property (weak, nonatomic) NSMenu *menu;

@end

@implementation BRFiltersMenuController

- (instancetype)init {
    return [self initWithPredicate:[BRBuildPredicate new] itemProvider: [BRFilterItemProvider new]];
}

- (instancetype)initWithPredicate:(BRBuildPredicate *)predicate itemProvider:(BRFilterItemProvider *)itemProvider {
    if (self = [super init]) {
        _predicate = predicate;
        _itemProvider = itemProvider;
    }
    
    return self;
}

- (void)bind:(NSMenu *)menu {
    self.menu = menu;
    
    [self.menu addItem:[NSMenuItem separatorItem]];
    [[self.itemProvider statusItems] enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
        [item setTarget:self];
        [item setAction:@selector(toggleStatus:)];
        [self.menu addItem:item];
    }];
    
    [self.menu addItem:[NSMenuItem separatorItem]];
    [[self.itemProvider appsItems] enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
        [item setTarget:self];
        [item setAction:@selector(toggleStatus:)];
        [self.menu addItem:item];
    }];
}

#pragma mark - Actions -

- (void)toggleStatus:(NSMenuItem *)item {
    if ([item.representedObject isKindOfClass:[BRFilterCondition class]]) {
        BRFilterCondition *condition = (BRFilterCondition *)item.representedObject;
        [self.predicate toggleCondition:condition];
        
        self.stateChageCallback(self.predicate);
    }
}

#pragma mark - NSMenuItemValidation -

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    // If all options disabled we dont want to display all checkmarks
    if (!self.predicate.hasConditions) {
        [menuItem setState:NSControlStateValueOff];
        return YES;
    }
    
    if ([menuItem.representedObject isKindOfClass:[BRFilterCondition class]]) {
        BRFilterCondition *condition = (BRFilterCondition *)menuItem.representedObject;
        [menuItem setState:[self.predicate hasCondition:condition] ? NSControlStateValueOn : NSControlStateValueOff];
    }
    
    return YES;
}


@end
