//
//  BRFilterItemProvider.m
//  BitBot
//
//  Created by Deszip on 12.10.2022.
//  Copyright © 2022 Bitrise. All rights reserved.
//

#import "BRFilterItemProvider.h"
#import "BRFilterStatusCondition.h"

@implementation BRFilterItemProvider

- (NSArray <NSMenuItem *> *)statusItems {
    NSMenuItem *successItem = [[NSMenuItem alloc] initWithTitle:@"Success" action:nil keyEquivalent:@""];
    [successItem setRepresentedObject:[[BRFilterStatusCondition alloc] initWithType:BRFilterStatusTypeSuccess]];
    
    NSMenuItem *failedItem = [[NSMenuItem alloc] initWithTitle:@"Failed" action:nil keyEquivalent:@""];
    [failedItem setRepresentedObject:[[BRFilterStatusCondition alloc] initWithType:BRFilterStatusTypeFailed]];
    
    NSMenuItem *abortedItem = [[NSMenuItem alloc] initWithTitle:@"Aborted" action:nil keyEquivalent:@""];
    [abortedItem setRepresentedObject:[[BRFilterStatusCondition alloc] initWithType:BRFilterStatusTypeAborted]];
    
    NSMenuItem *onHoldItem = [[NSMenuItem alloc] initWithTitle:@"On Hold" action:nil keyEquivalent:@""];
    [onHoldItem setRepresentedObject:[[BRFilterStatusCondition alloc] initWithType:BRFilterStatusTypeOnHold]];
    
    NSMenuItem *inProgressItem = [[NSMenuItem alloc] initWithTitle:@"In Progress" action:nil keyEquivalent:@""];
    [inProgressItem setRepresentedObject:[[BRFilterStatusCondition alloc] initWithType:BRFilterStatusTypeInProgress]];
    
    return @[successItem, failedItem, abortedItem, onHoldItem, inProgressItem];
}

@end
