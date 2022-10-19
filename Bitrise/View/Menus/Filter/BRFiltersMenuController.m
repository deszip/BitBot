//
//  BRFiltersMenuController.m
//  BitBot
//
//  Created by Deszip on 06.10.2022.
//  Copyright © 2022 Bitrise. All rights reserved.
//

#import "BRFiltersMenuController.h"

#import "BRMacro.h"
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
    return [self initWithPredicate:[BRBuildPredicate new]
                      itemProvider: [BRFilterItemProvider new]];
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
    
    [self addItems:[self.itemProvider statusItems] asSubmenuWithTitle:@"Status"];
    [self addItems:[self.itemProvider appsItems] asSubmenuWithTitle:@"Applications"];
    [self addItems:[self.itemProvider accountsItems] asSubmenuWithTitle:@"Accounts"];
    
    NSMenuItem *clearItem = [[NSMenuItem alloc] initWithTitle:@"Clear filter" action:@selector(clearFilter) keyEquivalent:@""];
    [clearItem setTarget:self];
    [self.menu addItem:[NSMenuItem separatorItem]];
    [self.menu addItem:clearItem];
    
    // Recover predicate
    self.predicate = [self savedPredicate];
    [self handleStateChange];
}

- (void)addItems:(NSArray <NSMenuItem *> *)items asSubmenuWithTitle:(NSString *)title {
    NSMenu *submenu = [NSMenu new];
    [items enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
        [item setTarget:self];
        [item setAction:@selector(toggleItem:)];
        [submenu addItem:item];
    }];
    NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:title action:nil keyEquivalent:@""];
    
    if (items.count < 2) {
        [menuItem setEnabled:NO];
    }
    
    [self.menu addItem:menuItem];
    [self.menu setSubmenu:submenu forItem:menuItem];
}

#pragma mark - Actions -

- (void)toggleItem:(NSMenuItem *)item {
    if ([item.representedObject isKindOfClass:[BRFilterCondition class]]) {
        BRFilterCondition *condition = (BRFilterCondition *)item.representedObject;
        [self.predicate toggleCondition:condition];
        
        [self handleStateChange];
    }
}

- (void)clearFilter {
    [self.predicate clear];
    [self.menu update];
    [self handleStateChange];
}

- (void)handleStateChange {
    [self savePredicate:self.predicate];
    BR_SAFE_CALL(self.stateChageCallback, self.predicate);
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

#pragma mark - Persistance

- (void)savePredicate:(BRBuildPredicate *)predicate {
    NSError *error;
    NSData *encodedPredicate = [NSKeyedArchiver archivedDataWithRootObject:predicate requiringSecureCoding:NO error:&error];
    if (encodedPredicate) {
        [[NSUserDefaults standardUserDefaults] setObject:encodedPredicate forKey:@"brpredicate"];
    } else {
        //...
    }
}

- (BRBuildPredicate *)savedPredicate {
    NSData *encodedPredicate = [[NSUserDefaults standardUserDefaults] objectForKey:@"brpredicate"];
    NSError *error;
    BRBuildPredicate *predicate = [NSKeyedUnarchiver unarchivedObjectOfClass:[BRBuildPredicate class] fromData:encodedPredicate error:&error];

    if (predicate) {
        return predicate;
    }
    
    return [BRBuildPredicate new];
}

@end
