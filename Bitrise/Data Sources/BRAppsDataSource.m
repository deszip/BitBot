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

@property (weak) NSOutlineView *outlineView;

@property (strong, nonatomic) NSPersistentContainer *container;
@property (strong, nonatomic) NSFetchedResultsController *frc;

@end

@implementation BRAppsDataSource

- (instancetype)initWithContainer:(NSPersistentContainer *)container outline:(NSOutlineView *)outline {
    if (self = [super init]) {
        _outlineView = outline;
        _outlineView.dataSource = self;
        _outlineView.delegate = self;
        
        _container = container;
        _frc = [self buildFRC:self.container.viewContext];
        [_frc setDelegate:self];
    }
    
    return self;
}

#pragma mark - Builders -

- (NSFetchedResultsController *)buildFRC:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [BRApp fetchRequest];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    [context setAutomaticallyMergesChangesFromParent:YES];
    return [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
}

- (void)buildStubs {
    BRApp *app = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([BRApp class]) inManagedObjectContext:self.container.viewContext];
    app.name = @"Foo App";
    
    BRBuild *build_1 = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([BRBuild class]) inManagedObjectContext:self.container.viewContext];
    build_1.workflow = @"workflow 1";
    build_1.branch = @"master";
    
    BRBuild *build_2 = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([BRBuild class]) inManagedObjectContext:self.container.viewContext];
    build_2.workflow = @"workflow 2";
    build_2.branch = @"master";
    
    [app addBuildsObject:build_1];
    [app addBuildsObject:build_2];
    
    NSError *saveError = nil;
    if (![self.container.viewContext save:&saveError]) {
        NSLog(@"Failed to save context: %@", saveError);
    }
}

#pragma mark - Actions -

- (void)fetch {
    NSError *fetchError = nil;
    if (![self.frc performFetch:&fetchError]) {
        NSLog(@"Failed to fetch apps: %@", fetchError);
    } else {
        NSLog(@"Fetched apps: %@", [self.frc.sections[0] objects]);
    }
    
    [self.outlineView reloadData];
}


#pragma mark - NSOutlineViewDataSource -

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (!item) {
        return [self.frc.sections[0] objects][index];
    }
    
    if ([item isKindOfClass:[BRApp class]]) {
        return [[(BRApp *)item builds] objectAtIndex:index];
    }
    
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return [item isKindOfClass:[BRApp class]] && [[(BRApp *)item builds] count] > 0;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if (!item) {
        return [[self.frc.sections[0] objects] count];
    }
    
    if ([item isKindOfClass:[BRApp class]]) {
        return [[(BRApp *)item builds] count];
    }
    
    return 0;
}

#pragma mark - NSOutlineViewDelegate -

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item {
    return 52.0;
}

- (NSTableRowView *)outlineView:(NSOutlineView *)outlineView rowViewForItem:(id)item {
    if ([item isKindOfClass:[BRApp class]]) {
        BRApp *app = (BRApp *)item;
        BRAppCellView *cell = [outlineView makeViewWithIdentifier:@"BRAppCellView" owner:self];
        [cell.appNameLabel setStringValue:app.name];
        
        return cell;
    }
    
    if ([item isKindOfClass:[BRBuild class]]) {
        BRBuild *build = (BRBuild *)item;
        BRBuildCellView *cell = [outlineView makeViewWithIdentifier:@"BRBuildCellView" owner:self];
        [cell.buildNameLabel setStringValue:[NSString stringWithFormat:@"%@ - %@", build.branch, build.workflow]];
        
        return cell;
    }
    
    return nil;
}

#pragma mark - NSFetchedResultsControllerDelegate -

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.outlineView reloadData];
}

@end
