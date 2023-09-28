//
//  BRAccountInfoViewController.m
//  BitBot
//
//  Created by Deszip on 21.11.2021.
//  Copyright © 2021 Bitrise. All rights reserved.
//

#import "BRAccountInfoViewController.h"

#import <SDWebImage/UIImageView+WebCache.h>

#import "BRLogger.h"
#import "BTRAccount+CoreDataClass.h"
#import "BRApp+CoreDataClass.h"
#import "BRAppsObserver.h"

@interface BRAccountInfoViewController ()

@property (strong, nonatomic) BRAccountsObserver *accountObserver;
@property (strong, nonatomic) NSNotificationCenter *notificationCenter;

@property (weak) IBOutlet NSImageView *avatarImageView;

@end

@implementation BRAccountInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _accountObserver = [self.dependencyContainer accountsObserver];
    
    _notificationCenter = [self.dependencyContainer notificationCenter];
    [self.notificationCenter addObserver:self selector:@selector(handleAccountSelection:) name:kAccountSelectedNotification object:nil];
}

#pragma mark - Notifications -

- (void)handleAccountSelection:(NSNotification *)notification {
    NSString *accSlug = notification.userInfo[@"AccountID"];
    [self.accountObserver startAccountObserving:accSlug callback:^(BTRAccount *account) {
        BRLog(LL_VERBOSE, LL_UI, @"Account selected: %@", account);
        [self updateAccount:account];
    }];
}

#pragma mark - UI update

- (void)updateAccount:(BTRAccount *)account {
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:account.avatarURL] placeholderImage:[NSImage imageNamed:@"avatar-default"]];
}

@end