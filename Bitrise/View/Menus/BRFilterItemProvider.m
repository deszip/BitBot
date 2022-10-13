//
//  BRFilterItemProvider.m
//  BitBot
//
//  Created by Deszip on 12.10.2022.
//  Copyright © 2022 Bitrise. All rights reserved.
//

#import "BRFilterItemProvider.h"

#import "BRLogger.h"
#import "BRFilterCondition.h"
#import "BRApp+CoreDataClass.h"

@interface BRFilterItemProvider ()

@property (strong, nonatomic) NSManagedObjectContext *context;

@end

@implementation BRFilterItemProvider

- (instancetype)initWithContext:(NSManagedObjectContext *)context {
    if (self = [super init]) {
        _context = context;
        [_context setAutomaticallyMergesChangesFromParent:YES];
    }
    
    return self;
}

- (NSArray <NSMenuItem *> *)appsItems {
    NSFetchRequest *request = [BRApp fetchRequest];
    NSError *fetchError;
    NSArray <BRApp *> *apps = [self.context executeFetchRequest:request error:&fetchError];
    
    if (!apps) {
        BRLog(LL_WARN, LL_STORAGE, @"Failed to fetch apps for filtering: %@", fetchError);
        return @[];
    }
    
    __block NSMutableArray *appsItems = [NSMutableArray array];
    [apps enumerateObjectsUsingBlock:^(BRApp *app, NSUInteger idx, BOOL *stop) {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:app.title action:nil keyEquivalent:@""];
        [item setRepresentedObject:[[BRFilterCondition alloc] initWithAppSlug:app.slug]];
        [appsItems addObject:item];
    }];
    
    return [appsItems copy];
}

- (NSArray <NSMenuItem *> *)statusItems {
    NSMenuItem *successItem = [[NSMenuItem alloc] initWithTitle:@"Success" action:nil keyEquivalent:@""];
    [successItem setRepresentedObject:[[BRFilterCondition alloc] initWithBuildStatus:BRFilterStatusTypeSuccess]];
    
    NSMenuItem *failedItem = [[NSMenuItem alloc] initWithTitle:@"Failed" action:nil keyEquivalent:@""];
    [failedItem setRepresentedObject:[[BRFilterCondition alloc] initWithBuildStatus:BRFilterStatusTypeFailed]];
    
    NSMenuItem *abortedItem = [[NSMenuItem alloc] initWithTitle:@"Aborted" action:nil keyEquivalent:@""];
    [abortedItem setRepresentedObject:[[BRFilterCondition alloc] initWithBuildStatus:BRFilterStatusTypeAborted]];
    
    NSMenuItem *onHoldItem = [[NSMenuItem alloc] initWithTitle:@"On Hold" action:nil keyEquivalent:@""];
    [onHoldItem setRepresentedObject:[[BRFilterCondition alloc] initWithBuildStatus:BRFilterStatusTypeOnHold]];
    
    NSMenuItem *inProgressItem = [[NSMenuItem alloc] initWithTitle:@"In Progress" action:nil keyEquivalent:@""];
    [inProgressItem setRepresentedObject:[[BRFilterCondition alloc] initWithBuildStatus:BRFilterStatusTypeInProgress]];
    
    return @[successItem, failedItem, abortedItem, onHoldItem, inProgressItem];
}

@end
