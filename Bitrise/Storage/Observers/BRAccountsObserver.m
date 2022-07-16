//
//  BRAccountsObserver.m
//  Bitrise
//
//  Created by Deszip on 20.06.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

#import "BRAccountsObserver.h"

#import "BRLogger.h"
#import "BRMacro.h"
#import "BTRAccount+CoreDataClass.h"

@interface BRAccountsObserver () <NSFetchedResultsControllerDelegate>

@property (copy, nonatomic) BRAccountsStateCallback stateCallback;
@property (copy, nonatomic) NSString *accountSlug;
@property (copy, nonatomic) BRAccountUpdateCallback accountCallback;

@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) NSFetchedResultsController *accountsFRC;

@end

@implementation BRAccountsObserver

- (instancetype)initWithContext:(NSManagedObjectContext *)context {
    if (self = [super init]) {
        _context = context;
        _accountsFRC = [self buildAccountsFRC:self.context];
        [_accountsFRC setDelegate:self];
    }
    
    return self;
}

#pragma mark - Builders -

- (NSFetchedResultsController *)buildAccountsFRC:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [BTRAccount fetchRequest];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"username" ascending:YES]];
    [context setAutomaticallyMergesChangesFromParent:YES];
    return [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
}

#pragma mark - Public API -

- (void)startStateObserving:(BRAccountsStateCallback)callback {
    [self fetch];
    
    self.stateCallback = callback;
    [self updateState];
}

- (void)startAccountObserving:(NSString *)accountSlug callback:(BRAccountUpdateCallback)callback {
    [self fetch];
    
    self.accountSlug = accountSlug;
    self.accountCallback = callback;
    [self updateAccount:accountSlug];
}

#pragma mark - NSFetchedResultsControllerDelegate -

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self updateState];
    [self updateAccount:self.accountSlug];
}

#pragma mark - Private -

- (void)fetch {
    NSError *fetchError = nil;
    if (![self.accountsFRC performFetch:&fetchError]) {
        BRLog(LL_WARN, LL_STORAGE, @"Failed to fetch apps: %@", fetchError);
    }
}

- (void)updateState {
    NSUInteger itemsCount = [[self.accountsFRC.sections valueForKeyPath:@"objects.@unionOfObjects.@count"][0] integerValue];
    BRAccountsState nextState = itemsCount == 0 ? BRAccountsStateEmpty : BRAccountsStateHasData;
    if (nextState != _state) {
        _state = nextState;
        BR_SAFE_CALL(self.stateCallback, self.state);
    }
}

- (void)updateAccount:(NSString *)accountSlug {
    NSArray *accounts = [[self.accountsFRC.sections valueForKeyPath:@"objects"][0] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"slug=%@", accountSlug]];
    
    if (accounts.firstObject) {
        BR_SAFE_CALL(self.accountCallback, accounts.firstObject);
    }
}

@end
