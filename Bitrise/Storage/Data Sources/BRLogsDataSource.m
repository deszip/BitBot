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

@interface BRLogsDataSource () <NSFetchedResultsControllerDelegate>

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
    NSFetchRequest *request = [BRLogChunk fetchRequest];
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
}

#pragma mark - NSFetchedResultsControllerDelegate -

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    NSString *log = @"";
    NSUInteger chunkCount = [controller.sections[0] numberOfObjects];
    for (NSUInteger i = 0; i < chunkCount; i++) {
        BRLogChunk *chunk = [controller objectAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        log = [log stringByAppendingString:chunk.text];
    }
    
    BR_SAFE_CALL(self.updateCallback, log);
}

@end
