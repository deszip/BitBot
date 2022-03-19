//
//  BRWindowController.m
//  BitBot
//
//  Created by Deszip on 10.10.2021.
//  Copyright © 2021 Bitrise. All rights reserved.
//

#import "BRWindowController.h"

#import "AppDelegate.h"

@interface BRWindowController ()

@end

@implementation BRWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    _dependencyContainer = [(AppDelegate *)[[NSApplication sharedApplication] delegate] dependencyContainer];
}

@end
