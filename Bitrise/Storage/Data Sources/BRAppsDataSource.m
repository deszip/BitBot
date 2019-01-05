//
//  BRAppsDataSource.m
//  Bitrise
//
//  Created by Deszip on 04/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BRAppsDataSource.h"

#import <CoreData/CoreData.h>

#import "BRAppCellView.h"
#import "BRBuildCellView.h"

#import "BRAccount+CoreDataClass.h"
#import "BRApp+CoreDataClass.h"
#import "BRBuild+CoreDataClass.h"

@interface BRAppsDataSource () <NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) NSOutlineView *outlineView;

@property (strong, nonatomic) BRCellBuilder *cellBuilder;
@property (strong, nonatomic) NSPersistentContainer *container;
@property (strong, nonatomic) NSFetchedResultsController *buildsFRC;

@end

@implementation BRAppsDataSource

- (instancetype)initWithContainer:(NSPersistentContainer *)container cellBuilder:(BRCellBuilder *)cellBuilder {
    if (self = [super init]) {
        _cellBuilder = cellBuilder;
        _container = container;
        _buildsFRC = [self buildBuildsFRC:self.container.viewContext];
        [_buildsFRC setDelegate:self];
        [self fetch];
        [self.outlineView reloadData];
    }
    
    return self;
}

- (void)bind:(NSOutlineView *)outlineView {
    _outlineView = outlineView;
    self.outlineView.dataSource = self;
    self.outlineView.delegate = self;
    [self.outlineView reloadData];
}

#pragma mark - Builders -

- (NSFetchedResultsController *)buildBuildsFRC:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [BRBuild fetchRequest];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"triggerTime" ascending:NO]];
    [context setAutomaticallyMergesChangesFromParent:YES];
    return [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
}

#pragma mark - Actions -

- (void)fetch {
    NSError *fetchError = nil;
    if (![self.buildsFRC performFetch:&fetchError]) {
        NSLog(@"Failed to fetch builds: %@", fetchError);
    }
    [self.outlineView reloadData];
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
    return 75.0;
}

- (NSTableRowView *)outlineView:(NSOutlineView *)outlineView rowViewForItem:(id)item {
    return [self.cellBuilder buildCell:item forOutline:outlineView];
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
