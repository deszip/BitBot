//
//  BRStandaloneTabViewController.m
//  BitBot
//
//  Created by Deszip on 21.11.2021.
//  Copyright © 2021 Bitrise. All rights reserved.
//

#import "BRStandaloneTabViewController.h"

@interface BRStandaloneTabViewController ()

@property (strong, nonatomic) NSNotificationCenter *notificationCenter;

@end

@implementation BRStandaloneTabViewController

- (void)viewDidAppear {
    [super viewDidAppear];
    
    self.notificationCenter = [self.dependencyContainer notificationCenter];
    [self.notificationCenter addObserver:self selector:@selector(handleTabSwitch:) name:kStandaloneTabSelectedNotification object:nil];
}

- (void)handleTabSwitch:(NSNotification *)notification {
    BRStandaloneTab tabIndex = [notification.userInfo[@"TabIndex"] integerValue];
    [self setSelectedTabViewItemIndex:tabIndex];
}

@end
