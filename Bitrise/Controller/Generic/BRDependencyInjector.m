//
//  BRDependencyInjector.m
//  BitBot
//
//  Created by Deszip on 10.10.2021.
//  Copyright © 2021 Bitrise. All rights reserved.
//

#import "BRDependencyInjector.h"

#import "BRWindowController.h"
#import "BRViewController.h"
#import "BRSplitViewController.h"

@implementation BRDependencyInjector

+ (void)propagateContainer:(id)container toSegue:(NSStoryboardSegue *)segue {
    id destination = segue.destinationController;
    
    if ([destination isKindOfClass:[BRWindowController class]]) {
        [(BRWindowController *)destination setDependencyContainer:container];
    }
    if ([destination isKindOfClass:[NSWindowController class]]) {
        NSViewController *contentController = [(NSWindowController *)destination contentViewController];
        [self propagateContainer:container toController:contentController];
    }
    if ([destination isKindOfClass:[NSViewController class]]) {
        [self propagateContainer:container toController:destination];
    }
}

+ (void)propagateContainer:(id)container toController:(NSViewController *)controller {
    if ([controller isKindOfClass:[BRViewController class]]) {
        [(BRViewController *)controller setDependencyContainer:container];
    }
    if ([controller isKindOfClass:[BRSplitViewController class]]) {
        [(BRSplitViewController *)controller setDependencyContainer:container];
    }
}

@end
