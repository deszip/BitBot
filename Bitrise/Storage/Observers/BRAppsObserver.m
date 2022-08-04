//
//  BRAppsObserver.m
//  Bitrise
//
//  Created by Deszip on 16.07.2022.
//  Copyright © 2022 Bitrise. All rights reserved.
//

#import "BRAppsObserver.h"

#import "BRLogger.h"
#import "BRMacro.h"
#import "BTRAccount+CoreDataClass.h"
#import "BRApp+CoreDataClass.h"

@interface BRAppsObserver () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) NSFetchedResultsController *appFRC;

@property (copy, nonatomic) NSString *appSlug;
@property (copy, nonatomic) BRAppUpdateCallback appCallback;

@end

@implementation BRAppsObserver

- (instancetype)initWithContext:(NSManagedObjectContext *)context {
    if (self = [super init]) {
        _context = context;
        _appFRC = [self buildAppFRC:self.context];
        [_appFRC setDelegate:self];
    }
    
    return self;
}

#pragma mark - Public API -

- (void)startAppObserving:(NSString *)appSlug callback:(BRAppUpdateCallback)callback {
    self.appSlug = appSlug;
    self.appCallback = callback;
    
    [self.appFRC.fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"slug=%@", appSlug]];
    [self fetch];
    
    [self updateApp:self.appSlug];
}

#pragma mark - NSFetchedResultsControllerDelegate -

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self updateApp:self.appSlug];
}

#pragma mark - Private -

- (void)fetch {
    NSError *fetchError = nil;
    if (![self.appFRC performFetch:&fetchError]) {
        BRLog(LL_WARN, LL_STORAGE, @"Failed to fetch apps: %@", fetchError);
    }
}

- (void)updateApp:(NSString *)appSlug {
    NSArray *apps = [[self.appFRC.sections valueForKeyPath:@"objects"][0] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"slug=%@", appSlug]];
    
    if (apps.firstObject) {
        BR_SAFE_CALL(self.appCallback, apps.firstObject);
    }
}

#pragma mark - Builders -

- (NSFetchedResultsController *)buildAppFRC:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [BRApp fetchRequest];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];
    [context setAutomaticallyMergesChangesFromParent:YES];
    return [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
}

@end
