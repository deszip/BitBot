//
//  BRLogsDataSource.m
//  Bitrise
//
//  Created by Deszip on 10/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "BRLogsDataSource.h"

#import "BRLogger.h"
#import "BRMacro.h"
#import "BRLogLine+CoreDataClass.h"
#import "BRLogStep+CoreDataClass.h"

#import "BRLogLineView.h"
#import "BRLogStepView.h"

@interface BRLogsDataSource () <NSOutlineViewDataSource, NSOutlineViewDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) BRLogPresenter *logPresenter;

@property (weak, nonatomic) NSOutlineView *outlineView;
@property (weak, nonatomic) NSTextView *textView;

@property (strong, nonatomic) NSPersistentContainer *container;
@property (strong, nonatomic) NSFetchedResultsController *logFRC;

@property (copy, nonatomic) NSString *buildSlug;

@end

@implementation BRLogsDataSource

- (instancetype)initWithContainer:(NSPersistentContainer *)container logPresenter:(BRLogPresenter *)presenter {
    if (self = [super init]) {
        _container = container;
        _logPresenter = presenter;
    }
    
    return self;
}

- (void)buildFRC:(NSManagedObjectContext *)context buildSlug:(NSString *)buildSlug {
    NSFetchRequest *linesRequest = [BRLogLine fetchRequest];
    linesRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"chunkPosition" ascending:YES],
                                     [NSSortDescriptor sortDescriptorWithKey:@"linePosition" ascending:YES]];
    linesRequest.predicate = [NSPredicate predicateWithFormat:@"log.build.slug = %@", buildSlug];
    [context setAutomaticallyMergesChangesFromParent:YES];
    self.logFRC = [[NSFetchedResultsController alloc] initWithFetchRequest:linesRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    [self.logFRC setDelegate:self];
}

- (void)fetch:(NSString *)buildSlug {
    if (!self.logFRC || ![self.buildSlug isEqualToString:buildSlug]) {
        self.buildSlug = buildSlug;
        [self buildFRC:self.container.viewContext buildSlug:buildSlug];
    }
    
    NSError *fetchError = nil;
    if (![self.logFRC performFetch:&fetchError]) {
        BRLog(LL_WARN, LL_STORAGE, @"Failed to fetch logs: %@ - %@", buildSlug, fetchError);
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
    [self.outlineView scrollToEndOfDocument:self];
    
    NSString *insertion = [self contentFromLine:0];
    NSAttributedString *attrLine = [self.logPresenter decoratedLine:insertion];
    [[self.textView textStorage] appendAttributedString:attrLine];
}

#pragma mark - Text processing -

- (NSString *)contentFromLine:(NSUInteger)startLine {
    NSUInteger lineCount = [[self.logFRC.sections[0] objects] count];
    NSMutableString *content = [@"" mutableCopy];
    for (NSUInteger lineIndex = startLine; lineIndex < lineCount; lineIndex++) {
        BRLogLine *line = [self.logFRC objectAtIndexPath:[NSIndexPath indexPathForItem:lineIndex inSection:0]];
        if (line) {
            [content appendString:line.text];
        }
    }
    
    return content;
}

#pragma mark - NSOutlineViewDelegate -

- (NSTableRowView *)outlineView:(NSOutlineView *)outlineView rowViewForItem:(id)item {
    if ([item isKindOfClass:[BRLogLine class]]) {
        BRLogLine *line = (BRLogLine *)item;
        BRLogLineView *cell = [outlineView makeViewWithIdentifier:@"BRLogLineView" owner:self];
        NSString *logLine = [line.text stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        [cell.lineLabel setAttributedStringValue:[self.logPresenter decoratedLine:logLine]];
        
        return cell;
    }
    
    if ([item isKindOfClass:[BRLogStep class]]) {
        BRLogStep *step = (BRLogStep *)item;
        BRLogStepView *cell = [outlineView makeViewWithIdentifier:@"BRLogStepView" owner:self];
        [cell.stepLabel setStringValue:step.name];
        
        return cell;
    }
    
    return nil;
}

#pragma mark - NSFetchedResultsControllerDelegate -

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self updateContent];
}

@end
