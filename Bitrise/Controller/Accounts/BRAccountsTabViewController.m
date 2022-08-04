//
//  BRAccountsTabViewController.m
//  BitBot
//
//  Created by Deszip on 04.08.2022.
//  Copyright © 2022 Bitrise. All rights reserved.
//

#import "BRAccountsTabViewController.h"

@interface BRAccountsTabViewController ()

@property (strong, nonatomic) NSNotificationCenter *notificationCenter;

@end

@implementation BRAccountsTabViewController

- (void)viewDidAppear {
    [super viewDidAppear];
    
    _notificationCenter = [self.dependencyContainer notificationCenter];
    [self.notificationCenter addObserver:self selector:@selector(handleAccountSelection:) name:kAccountSelectedNotification object:nil];
    [self.notificationCenter addObserver:self selector:@selector(handleAppSelection:) name:kAppSelectedNotification object:nil];
}

#pragma mark - Notifications -

- (void)handleAccountSelection:(NSNotification *)notification {
    [self setSelectedTabViewItemIndex:0];
}

- (void)handleAppSelection:(NSNotification *)notification {
    [self setSelectedTabViewItemIndex:1];
}

@end
