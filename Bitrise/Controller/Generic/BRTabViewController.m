//
//  BRTabViewController.m
//  BitBot
//
//  Created by Deszip on 21.11.2021.
//  Copyright © 2021 Bitrise. All rights reserved.
//

#import "BRTabViewController.h"

#import "BRDependencyInjector.h"

@implementation BRTabViewController

- (void)setDependencyContainer:(id)dependencyContainer {
    _dependencyContainer = dependencyContainer;
    [self.tabViewItems enumerateObjectsUsingBlock:^(__kindof NSTabViewItem *item, NSUInteger idx, BOOL *stop) {
        [BRDependencyInjector propagateContainer:self.dependencyContainer toController:item.viewController];
    }];
}

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
    [BRDependencyInjector propagateContainer:self.dependencyContainer toSegue:segue];
}

@end
