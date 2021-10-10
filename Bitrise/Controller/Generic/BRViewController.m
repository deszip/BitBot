//
//  BRViewController.m
//  BitBot
//
//  Created by Deszip on 06/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRViewController.h"

#import "BRStyleSheet.h"
#import "BRDependencyInjector.h"

@interface BRViewController ()

@end

@implementation BRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setWantsLayer:YES];
}

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
    [BRDependencyInjector propagateContainer:self.dependencyContainer toSegue:segue];
}

@end
