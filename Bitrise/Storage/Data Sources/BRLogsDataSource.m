//
//  BRLogsDataSource.m
//  Bitrise
//
//  Created by Deszip on 10/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "BRLogsDataSource.h"

#import "BRMacro.h"
#import "BRLogChunk+CoreDataClass.h"
#import "BRLogLine+CoreDataClass.h"

#import "BRLogLineView.h"

@interface BRLogsDataSource () <NSOutlineViewDataSource, NSOutlineViewDelegate, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) NSOutlineView *outlineView;

@property (strong, nonatomic) NSPersistentContainer *container;
@property (strong, nonatomic) NSFetchedResultsController *logFRC;

@property (copy, nonatomic) NSString *buildSlug;

@end

@implementation BRLogsDataSource

- (instancetype)initWithContainer:(NSPersistentContainer *)container {
    if (self = [super init]) {
        _container = container;
    }
    
    return self;
}

- (NSFetchedResultsController *)buildFRC:(NSManagedObjectContext *)context buildSlug:(NSString *)buildSlug {
    NSFetchRequest *request = [BRLogLine fetchRequest];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"log.build.slug = %@", buildSlug];
    [context setAutomaticallyMergesChangesFromParent:YES];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
}

- (void)fetch:(NSString *)buildSlug {
    if (!self.logFRC || ![self.buildSlug isEqualToString:buildSlug]) {
        self.buildSlug = buildSlug;
        self.logFRC = [self buildFRC:self.container.viewContext buildSlug:buildSlug];
        [self.logFRC setDelegate:self];
    }
    
    NSError *fetchError = nil;
    if (![self.logFRC performFetch:&fetchError]) {
        NSLog(@"Failed to fetch logs: %@ - %@", buildSlug, fetchError);
    }
    
    //[self updateContent];
    [self.outlineView reloadData];
}

- (void)bind:(NSOutlineView *)outlineView {
    _outlineView = outlineView;
    self.outlineView.dataSource = self;
    self.outlineView.delegate = self;
    [self.outlineView reloadData];
}

#pragma mark - NSOutlineViewDataSource -

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    return [self.logFRC.sections[0] objects][index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return NO;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    return [[self.logFRC.sections[0] objects] count];
}

#pragma mark - NSOutlineViewDelegate -

- (NSTableRowView *)outlineView:(NSOutlineView *)outlineView rowViewForItem:(id)item {
    if ([item isKindOfClass:[BRLogLine class]]) {
        BRLogLine *line = (BRLogLine *)item;
        BRLogLineView *cell = [outlineView makeViewWithIdentifier:@"BRLogLineView" owner:self];
        [cell.lineLabel setStringValue:line.text];
        
        return cell;
    }
    
    return nil;
}

#pragma mark - NSFetchedResultsControllerDelegate -

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.outlineView reloadData];
    [self.outlineView scrollToEndOfDocument:nil];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if (type == NSFetchedResultsChangeInsert) {
        //BR_SAFE_CALL(self.insertCallback, [anObject text]);
    }
}

#pragma mark - Content loading -

- (void)updateContent {
    NSString *log = [self currentLog:self.logFRC];
    if (log.length > 0) {
        //BR_SAFE_CALL(self.updateCallback, log);
    }
}

- (NSString *)currentLog:(NSFetchedResultsController *)frc {
    NSString *log = @"";
    NSUInteger chunkCount = [frc.sections[0] numberOfObjects];
    for (NSUInteger i = 0; i < chunkCount; i++) {
        BRLogChunk *chunk = [frc objectAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        log = [log stringByAppendingString:chunk.text];
    }
    
    return log;
}

@end
