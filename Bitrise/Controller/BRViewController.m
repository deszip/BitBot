//
//  BRViewController.m
//  Bitrise
//
//  Created by Deszip on 06/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BRViewController.h"

@interface BRViewController ()

@end

@implementation BRViewController

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
    id destination = segue.destinationController;
    BRViewController *nextController = nil;
    
    if ([destination isKindOfClass:[BRViewController class]]) {
        nextController = destination;
    } else if ([destination isKindOfClass:[NSWindowController class]]) {
        NSViewController *contentController = [(NSWindowController *)destination contentViewController];
        if ([contentController isKindOfClass:[BRViewController class]]) {
            nextController = (BRViewController *)contentController;
        }
    }
    
    if (nextController) {
        nextController.dependencyContainer = self.dependencyContainer;
    }
}

@end
