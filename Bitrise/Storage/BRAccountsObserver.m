//
//  BRAccountsObserver.m
//  Bitrise
//
//  Created by Deszip on 20.06.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

#import "BRAccountsObserver.h"

#import "BRLogger.h"
#import "BTRAccount+CoreDataClass.h"

@interface BRAccountsObserver () <NSFetchedResultsControllerDelegate>

@property (copy, nonatomic) void (^stateCallback)(BRAccountsState);

@property (strong, nonatomic) NSPersistentContainer *container;
@property (strong, nonatomic) NSFetchedResultsController *accountsFRC;

@end

@implementation BRAccountsObserver

- (instancetype)initWithContainer:(NSPersistentContainer *)container {
    if (self = [super init]) {
        _container = container;
        _accountsFRC = [self buildAccountsFRC:self.container.viewContext];
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

- (void)start:(BRAccountsStateCallback)callback {
    self.stateCallback = callback;
    
    NSError *fetchError = nil;
    if (![self.accountsFRC performFetch:&fetchError]) {
        BRLog(LL_WARN, LL_STORAGE, @"Failed to fetch apps: %@", fetchError);
    }
    
    [self updateState];
}

#pragma mark - NSFetchedResultsControllerDelegate -

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self updateState];
}

#pragma mark - Private -

- (void)updateState {
    NSUInteger itemsCount = [[self.accountsFRC.sections valueForKeyPath:@"objects.@unionOfObjects.@count"][0] integerValue];
    BRAccountsState nextState = itemsCount == 0 ? BRAccountsStateEmpty : BRAccountsStateHasData;
    if (nextState != _state) {
        _state = nextState;
        self.stateCallback(self.state);
    }
}
@end
