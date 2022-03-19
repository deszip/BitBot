//
//  BRViewController.m
//  BitBot
//
//  Created by Deszip on 06/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRViewController.h"

#import "AppDelegate.h"
#import "BRStyleSheet.h"

@interface BRViewController ()

@end

@implementation BRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setWantsLayer:YES];
    _dependencyContainer = [(AppDelegate *)[[NSApplication sharedApplication] delegate] dependencyContainer];
}

@end
