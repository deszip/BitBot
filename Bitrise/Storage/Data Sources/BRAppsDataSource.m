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
@property (strong, nonatomic) NSFetchedResultsController *appsFRC;
@property (strong, nonatomic) NSFetchedResultsController *buildsFRC;
@property (strong, nonatomic) NSFetchedResultsController *activeFRC;

@end

@implementation BRAppsDataSource

- (instancetype)initWithContainer:(NSPersistentContainer *)container cellBuilder:(BRCellBuilder *)cellBuilder {
    if (self = [super init]) {
        _cellBuilder = cellBuilder;
        _container = container;
        _appsFRC = [self buildAppsFRC:self.container.viewContext];
        [_appsFRC setDelegate:self];
        _buildsFRC = [self buildBuildsFRC:self.container.viewContext];
        [_buildsFRC setDelegate:self];
        
        [self setPresentationStyle:BRPresentationStyleList];
    }
    
    return self;
}

- (void)setPresentationStyle:(BRPresentationStyle)presentationStyle {
    _presentationStyle = presentationStyle;
    
    switch (presentationStyle) {
        case BRPresentationStyleList: self.activeFRC = self.buildsFRC; break;
        case BRPresentationStyleTree: self.activeFRC = self.appsFRC; break;
    }
    
    [self fetch];
    [self.outlineView reloadData];
}

- (void)bind:(NSOutlineView *)outlineView {
    _outlineView = outlineView;
    self.outlineView.dataSource = self;
    self.outlineView.delegate = self;
    [self.outlineView reloadData];
}

#pragma mark - Builders -

- (NSFetchedResultsController *)buildAppsFRC:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [BRApp fetchRequest];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];
    [context setAutomaticallyMergesChangesFromParent:YES];
    return [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
}

- (NSFetchedResultsController *)buildBuildsFRC:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [BRBuild fetchRequest];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"buildNumber" ascending:NO]];
    [context setAutomaticallyMergesChangesFromParent:YES];
    return [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
}

#pragma mark - Actions -

- (void)fetch {
    NSError *fetchError = nil;
    if (![self.activeFRC performFetch:&fetchError]) {
        NSLog(@"Failed to fetch apps: %@", fetchError);
    }
    [self.outlineView reloadData];
}


#pragma mark - NSOutlineViewDataSource -

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (self.presentationStyle == BRPresentationStyleTree) {
        if (!item) {
            return [self.activeFRC.sections[0] objects][index];
        }
        
        if ([item isKindOfClass:[BRApp class]]) {
            return [[(BRApp *)item builds] objectAtIndex:index];
        }
    } else {
        return [self.activeFRC.sections[0] objects][index];
    }
    
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if (self.presentationStyle == BRPresentationStyleTree) {
        return [item isKindOfClass:[BRApp class]] && [[(BRApp *)item builds] count] > 0;
    }
    
    return NO;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if (self.presentationStyle == BRPresentationStyleTree) {
        if (!item) {
            return [[self.activeFRC.sections[0] objects] count];
        }
        
        if ([item isKindOfClass:[BRApp class]]) {
            return [[(BRApp *)item builds] count];
        }
    } else {
        return [[self.activeFRC.sections[0] objects] count];
    }
    
    return 0;
}

#pragma mark - NSOutlineViewDelegate -

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item {
    if ([item isKindOfClass:[BRApp class]]) {
        return 45.0;
    }
    
    if ([item isKindOfClass:[BRBuild class]]) {
        return 75.0;
    }
    
    return 0;
}

- (NSTableRowView *)outlineView:(NSOutlineView *)outlineView rowViewForItem:(id)item {
    if ([item isKindOfClass:[BRApp class]]) {
        return [self.cellBuilder appCell:item forOutline:outlineView];
    }
    
    if ([item isKindOfClass:[BRBuild class]]) {
        return [self.cellBuilder buildCell:item forOutline:outlineView];
    }
    
    return nil;
}

#pragma mark - NSFetchedResultsControllerDelegate -

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.outlineView reloadData];
}

@end
