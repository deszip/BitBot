//
//  BRTabViewController.m
//  BitBot
//
//  Created by Deszip on 21.11.2021.
//  Copyright © 2021 Bitrise. All rights reserved.
//

#import "BRTabViewController.h"

#import "AppDelegate.h"

@implementation BRTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _dependencyContainer = [(AppDelegate *)[[NSApplication sharedApplication] delegate] dependencyContainer];
}

@end
