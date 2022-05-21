//
//  BRSplitViewController.m
//  BitBot
//
//  Created by Deszip on 10.10.2021.
//  Copyright © 2021 Bitrise. All rights reserved.
//

#import "BRSplitViewController.h"

#import "AppDelegate.h"

@interface BRSplitViewController ()

@end

@implementation BRSplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.splitView setPosition:300.0 ofDividerAtIndex:0];

    _dependencyContainer = [(AppDelegate *)[[NSApplication sharedApplication] delegate] dependencyContainer];
}

@end
