//
//  BRViewController.m
//  BitBot
//
//  Created by Deszip on 06/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRViewController.h"

#import "BRStyleSheet.h"

@interface BRViewController ()

@end

@implementation BRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setWantsLayer:YES];
    [self.view.layer setBackgroundColor:[BRStyleSheet backgroundColor].CGColor];
}

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
