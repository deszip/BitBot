//
//  BRAccountInfoViewController.m
//  BitBot
//
//  Created by Deszip on 21.11.2021.
//  Copyright © 2021 Bitrise. All rights reserved.
//

#import "BRAccountInfoViewController.h"

#import "BRLogger.h"

@interface BRAccountInfoViewController ()

@property (strong, nonatomic) BRAccountsObserver *accountObserver;
@property (strong, nonatomic) NSNotificationCenter *notificationCenter;

@end

@implementation BRAccountInfoViewController

- (void)viewDidAppear {
    [super viewDidAppear];
    
    _accountObserver = [self.dependencyContainer accountsObserver];
    
    _notificationCenter = [self.dependencyContainer notificationCenter];
    [self.notificationCenter addObserver:self selector:@selector(handleAccountSelection:) name:kAccountSelectedNotification object:nil];
}

#pragma mark - Notifications -

- (void)handleAccountSelection:(NSNotification *)notification {
    NSString *accSlug = notification.userInfo[@"AccountID"];
    [self.accountObserver startAccountObserving:accSlug callback:^(BTRAccount *account) {
        BRLog(LL_VERBOSE, LL_UI, @"Account selected: %@", account);
    }];
}

@end
