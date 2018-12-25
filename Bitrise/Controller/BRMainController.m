//
//  BRMainController.m
//  Bitrise
//
//  Created by Deszip on 04/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BRMainController.h"

#import "BRContainerBuilder.h"
#import "BRAppsDataSource.h"
#import "BRAccountsViewController.h"

#import "BRSyncCommand.h"
#import "BRBuildStateInfo.h"
#import "BRSettingsMenuController.h"
#import "BRBuildMenuController.h"
#import "BRSegue.h"

typedef NS_ENUM(NSUInteger, BRBuildMenuItem) {
    BRBuildMenuItemUndefined = 0,
    BRBuildMenuItemRebuild,
    BRBuildMenuItemAbort,
    BRBuildMenuItemDownload,
    BRBuildMenuItemOpenBuild
};

@interface BRMainController () <NSMenuDelegate>

@property (strong, nonatomic) BRBitriseAPI *api;
@property (strong, nonatomic) BRStorage *storage;
@property (strong, nonatomic) BRSyncEngine *syncEngine;

@property (strong, nonatomic) BRAppsDataSource *dataSource;

@property (strong, nonatomic) BRSettingsMenuController *settingsController;
@property (strong, nonatomic) BRBuildMenuController *buildController;

@property (weak) IBOutlet NSOutlineView *outlineView;
@property (strong) IBOutlet NSMenu *buildMenu;
@property (strong) IBOutlet NSMenu *settingsMenu;

@end

@implementation BRMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.syncEngine = [self.dependencyContainer syncEngine];
    
    self.dataSource = [self.dependencyContainer appsDataSource];
    [self.dataSource bind:self.outlineView];
    
    self.settingsController = [[BRSettingsMenuController alloc] initWithEnvironment:[self.dependencyContainer environment]];
    [self.settingsController bind:self.settingsMenu];
    __weak __typeof (self) weakSelf = self;
    [self.settingsController setNavigationCallback:^(BRSettingsMenuNavigationAction action) {
        switch (action) {
            case BRSettingsMenuNavigationActionAccounts:
                [weakSelf performSegueWithIdentifier:kAccountWindowSegue sender:weakSelf];
                break;
                
            case BRSettingsMenuNavigationActionAbout:
                [weakSelf performSegueWithIdentifier:kAboutWindowSegue sender:weakSelf];
                break;
                
            default: break;
        }
    }];
    
    self.buildController = [BRBuildMenuController new];
    [self.buildController bind:self.buildMenu toOutline:self.outlineView];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    [self.dataSource fetch];
}

#pragma mark - Actions -

- (IBAction)openSettingsMenu:(NSButton *)sender {
    NSPoint point = NSMakePoint(0.0, sender.bounds.size.height + 5.0);
    [self.settingsMenu popUpMenuPositioningItem:nil atLocation:point inView:sender];
}

@end
