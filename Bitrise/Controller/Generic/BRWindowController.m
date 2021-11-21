//
//  BRWindowController.m
//  BitBot
//
//  Created by Deszip on 10.10.2021.
//  Copyright © 2021 Bitrise. All rights reserved.
//

#import "BRWindowController.h"

#import "BRDependencyInjector.h"

@interface BRWindowController ()

@end

@implementation BRWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
}

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
    [BRDependencyInjector propagateContainer:self.dependencyContainer toSegue:segue];
}

- (void)setDependencyContainer:(id)dependencyContainer {
    _dependencyContainer = dependencyContainer;
    [self didSetContainer];
}

- (void)didSetContainer {
    //...
}

@end
