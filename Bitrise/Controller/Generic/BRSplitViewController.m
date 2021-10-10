//
//  BRSplitViewController.m
//  BitBot
//
//  Created by Deszip on 10.10.2021.
//  Copyright © 2021 Bitrise. All rights reserved.
//

#import "BRSplitViewController.h"

#import "BRDependencyInjector.h"

@interface BRSplitViewController ()

@end

@implementation BRSplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setDependencyContainer:(id)dependencyContainer {
    _dependencyContainer = dependencyContainer;
    [self.splitViewItems enumerateObjectsUsingBlock:^(__kindof NSSplitViewItem *item, NSUInteger idx, BOOL *stop) {
        [BRDependencyInjector propagateContainer:self.dependencyContainer toController:item.viewController];
    }];
}

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
    [BRDependencyInjector propagateContainer:self.dependencyContainer toSegue:segue];
}

@end
