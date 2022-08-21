//
//  BRAppInfoViewController.m
//  BitBot
//
//  Created by Deszip on 04.08.2022.
//  Copyright © 2022 Bitrise. All rights reserved.
//

#import "BRAppInfoViewController.h"

#import <SDWebImage/UIImageView+WebCache.h>

#import "BRLogger.h"
#import "BRApp+CoreDataClass.h"
#import "BRAppsObserver.h"

@interface BRAppInfoViewController ()

@property (strong, nonatomic) BRAppsObserver *appsObserver;
@property (strong, nonatomic) NSNotificationCenter *notificationCenter;

@property (weak) IBOutlet NSImageView *appIcon;

@end

@implementation BRAppInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _appsObserver = [self.dependencyContainer appsObserver];
    _notificationCenter = [self.dependencyContainer notificationCenter];
    
    [self.notificationCenter addObserver:self selector:@selector(handleAppSelection:) name:kAppSelectedNotification object:nil];
}

#pragma mark - Notifications -

- (void)handleAppSelection:(NSNotification *)notification {
    NSString *appSlug = notification.userInfo[@"AppID"];
    BRLog(LL_VERBOSE, LL_UI, @"App selected: %@", appSlug);
    
    [self.appsObserver startAppObserving:appSlug callback:^(BRApp *app) {
        [self updateApp:app];
    }];
}

#pragma mark - UI update

- (void)updateApp:(BRApp *)app {
    [self.appIcon sd_setImageWithURL:[NSURL URLWithString:app.avatarURL] placeholderImage:[NSImage imageNamed:@"avatar-default"]];
}

@end
