//
//  BRAppsDataSource.m
//  BitBot
//
//  Created by Deszip on 04/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRAppsDataSource.h"

#import <CoreData/CoreData.h>

#import "BRLogger.h"

#import "BRAppCellView.h"
#import "BRBuildCellView.h"

#import "BTRAccount+CoreDataClass.h"
#import "BRApp+CoreDataClass.h"
#import "BRBuild+CoreDataClass.h"

@interface BRAppsDataSource () <NSFetchedResultsControllerDelegate, NSOutlineViewDataSource, NSOutlineViewDelegate>

@property (weak, nonatomic) NSOutlineView *outlineView;

@property (strong, nonatomic) BRCellBuilder *cellBuilder;
@property (strong, nonatomic) NSPersistentContainer *container;
@property (strong, nonatomic) NSFetchedResultsController *buildsFRC;

@property (copy, nonatomic) void (^stateCallback)(BRBuildsState);

@end

@implementation BRAppsDataSource

- (instancetype)initWithContainer:(NSPersistentContainer *)container cellBuilder:(BRCellBuilder *)cellBuilder {
    if (self = [super init]) {
        _cellBuilder = cellBuilder;
        _container = container;
        _buildsFRC = [self buildBuildsFRC:self.container.viewContext];
        [_buildsFRC setDelegate:self];
        [self fetch];
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
    if (![self.buildsFRC performFetch:&fetchError]) {
        BRLog(LL_WARN, LL_STORAGE, @"Failed to fetch builds: %@", fetchError);
    }
    [self.outlineView reloadData];
    [self updateState];
}

#pragma mark - Filtering -

- (void)applyPredicate:(BRBuildPredicate *)predicate {
    if (!predicate) {
        self.buildsFRC.fetchRequest.predicate = nil;
    } else {
        self.buildsFRC.fetchRequest.predicate = [predicate predicate];
    }
    [self fetch];
}

- (void)setStateCallback:(BRBuildsStateCallback)callback {
    _stateCallback = callback;
    [self updateState];
}

#pragma mark - Builders -

- (NSFetchedResultsController *)buildBuildsFRC:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [BRBuild fetchRequest];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"triggerTime" ascending:NO]];
    [context setAutomaticallyMergesChangesFromParent:YES];
    return [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
}

#pragma mark - Private

- (void)updateState {
    NSUInteger itemsCount = [[self.buildsFRC.sections valueForKeyPath:@"objects.@unionOfObjects.@count"][0] integerValue];
    BRBuildsState nextState = itemsCount == 0 ? BRBuildsStateEmpty : BRBuildsStateHasData;
    if (nextState != _state) {
        _state = nextState;
        BR_SAFE_CALL(self.stateCallback, self.state);
    }
}

#pragma mark - NSOutlineViewDataSource -

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    return [self.buildsFRC.sections[0] objects][index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return NO;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    return [[self.buildsFRC.sections[0] objects] count];
}

#pragma mark - NSOutlineViewDelegate -

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item {
    return 115.0;
}

- (NSTableRowView *)outlineView:(NSOutlineView *)outlineView rowViewForItem:(id)item {
    BRBuildCellView *cell = [self.cellBuilder buildCell:item forOutline:outlineView];
    return cell;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
    return NO;
}

#pragma mark - NSFetchedResultsControllerDelegate -

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    switch (type) {
        case NSFetchedResultsChangeDelete:
        case NSFetchedResultsChangeUpdate:
            [self.outlineView reloadData];
            break;

        case NSFetchedResultsChangeInsert:
            [self.outlineView insertItemsAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.item] inParent:nil withAnimation:NSTableViewAnimationEffectGap];
            break;

        case NSFetchedResultsChangeMove:
            [self.outlineView moveItemAtIndex:indexPath.item inParent:nil toIndex:newIndexPath.item inParent:nil];
            break;
    }
}

@end
