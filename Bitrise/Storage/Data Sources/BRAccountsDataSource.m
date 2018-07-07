//
//  BRAccountsDataSource.m
//  Bitrise
//
//  Created by Deszip on 06/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BRAccountsDataSource.h"

#import <CoreData/CoreData.h>
#import "BRAccount+CoreDataClass.h"
#import "BRAccountCellView.h"

@interface BRAccountsDataSource () <NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) NSOutlineView *outlineView;

@property (strong, nonatomic) NSPersistentContainer *container;
@property (strong, nonatomic) NSFetchedResultsController *accountsFRC;

@end

@implementation BRAccountsDataSource

- (instancetype)initWithContainer:(NSPersistentContainer *)container {
    if (self = [super init]) {
        _container = container;
        _accountsFRC = [self buildAccountsFRC:self.container.viewContext];
        [_accountsFRC setDelegate:self];
    }
    
    return self;
}

#pragma mark - Actions -

- (void)bind:(NSOutlineView *)outlineView {
    _outlineView = outlineView;
    self.outlineView.dataSource = self;
    self.outlineView.delegate = self;
    [self.outlineView reloadData];
}

- (void)fetch {
    NSError *fetchError = nil;
    if (![self.accountsFRC performFetch:&fetchError]) {
        NSLog(@"Failed to fetch apps: %@", fetchError);
    } else {
        NSLog(@"Fetched accounts: %@", [self.accountsFRC.sections[0] objects]);
    }
    
    [self.outlineView reloadData];
}

#pragma mark - Builders -

- (NSFetchedResultsController *)buildAccountsFRC:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [BRAccount fetchRequest];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"username" ascending:YES]];
    [context setAutomaticallyMergesChangesFromParent:YES];
    return [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
}

#pragma mark - NSOutlineViewDataSource -

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    return [self.accountsFRC.sections[0] objects][index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return NO;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    return [[self.accountsFRC.sections[0] objects] count];
}

#pragma mark - NSOutlineViewDelegate -

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item {
    return 52.0;
}

- (NSTableRowView *)outlineView:(NSOutlineView *)outlineView rowViewForItem:(id)item {
    if ([item isKindOfClass:[BRAccount class]]) {
        BRAccount *account = (BRAccount *)item;
        BRAccountCellView *cell = [outlineView makeViewWithIdentifier:@"BRAccountCellView" owner:self];
        
        if (account.username) {
            [cell.accountNameLabel setStringValue:account.username];
        }
        
        return cell;
    }

    return nil;
}

#pragma mark - NSFetchedResultsControllerDelegate -

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.outlineView reloadData];
}

@end
