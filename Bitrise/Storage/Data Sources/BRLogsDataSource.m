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
#import "BRLogLine+CoreDataClass.h"

#import "BRLogLineView.h"

@interface BRLogsDataSource () <NSOutlineViewDataSource, NSOutlineViewDelegate, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) NSOutlineView *outlineView;
@property (weak, nonatomic) NSTextView *textView;

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
    
    [self updateContent];
}

- (void)bindOutlineView:(NSOutlineView *)outlineView {
    _outlineView = outlineView;
    self.outlineView.dataSource = self;
    self.outlineView.delegate = self;
    [self.outlineView reloadData];
}

- (void)bindTextView:(NSTextView *)textView {
    _textView = textView;
}

#pragma mark - Log updates -

- (void)updateContent {
    [self.outlineView reloadData];
    
    BOOL hasSelection = self.textView.selectedRange.length > 0;
    if (hasSelection) {
        return;
    }
    
    BOOL needsScroll = (NSMaxY(self.textView.bounds) - NSMaxY(self.textView.visibleRect)) < 100;
    NSString *insertion = [self contentFromLine:0];
    [self.textView setString:insertion];
    if (needsScroll) {
        [self.textView scrollRangeToVisible: NSMakeRange(self.textView.string.length, 0)];
    }
}

#pragma mark - Text processing -

- (NSString *)contentFromLine:(NSUInteger)startLine {
    NSUInteger lineCount = [[self.logFRC.sections[0] objects] count];
    NSMutableString *content = [@"" mutableCopy];
    for (NSUInteger lineIndex = startLine; lineIndex < lineCount; lineIndex++) {
        BRLogLine *line = [self.logFRC objectAtIndexPath:[NSIndexPath indexPathForItem:lineIndex inSection:0]];
        if (line) {
            [content appendString:line.text];
            //[content appendString:@"\n"];
        }
    }
    
    return content;
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
    [self updateContent];
}

@end
