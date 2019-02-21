//
//  BRMainController.m
//  BitBot
//
//  Created by Deszip on 04/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRMainController.h"

#import "BRContainerBuilder.h"
#import "BRAppsDataSource.h"
#import "BRAccountsViewController.h"

#import "BRSyncCommand.h"
#import "BRBuildStateInfo.h"
#import "BRSettingsMenuController.h"
#import "BRBuildMenuController.h"
#import "BRLogsViewController.h"
#import "BRLogsTextViewController.h"
#import "BRSegue.h"
#import "BRLogsWindowPresenter.h"


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
@property (strong, nonatomic) BREnvironment *environment;

@property (strong, nonatomic) BRAppsDataSource *dataSource;
@property (strong, nonatomic) BRSettingsMenuController *settingsController;
@property (strong, nonatomic) BRBuildMenuController *buildController;
@property (strong, nonatomic) BRLogsWindowPresenter *logsPresenter;

@property (weak) IBOutlet NSOutlineView *outlineView;
@property (strong) IBOutlet NSMenu *buildMenu;
@property (strong) IBOutlet NSMenu *settingsMenu;

@end

@implementation BRMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.logsPresenter = [[BRLogsWindowPresenter alloc] initWithPresentingController:self];
    
    self.syncEngine = [self.dependencyContainer syncEngine];
    self.environment = [self.dependencyContainer appEnvironment];
    
    self.dataSource = [self.dependencyContainer appsDataSource];
    [self.dataSource bind:self.outlineView];
    
    self.settingsController = [[BRSettingsMenuController alloc] initWithEnvironment:self.environment];
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
    
    self.buildController = [[BRBuildMenuController alloc] initWithAPI:[self.dependencyContainer bitriseAPI]
                                                           syncEngine:self.syncEngine
                                                          logObserver:[self.dependencyContainer logObserver]
                                                          environment:self.environment];
    [self.buildController bind:self.buildMenu toOutline:self.outlineView];
    [self.buildController setActionCallback:^(BRBuildMenuAction action, BRBuildInfo *buildInfo) {
        if (action == BRBuildMenuActionShowLog) {
            [weakSelf.logsPresenter presentLogs:buildInfo];
        }
    }];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    [self.dataSource fetch];
}

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    [[(NSWindowController *)segue.destinationController window] makeKeyAndOrderFront:self];
    [[(NSWindowController *)segue.destinationController window] setLevel:NSFloatingWindowLevel];
    
    if ([segue.identifier isEqualToString:kLogWindowSegue]) {
        BRLogsTextViewController *logController = (BRLogsTextViewController *)[(NSWindowController *)segue.destinationController contentViewController];
        [logController setBuildInfo:(BRBuildInfo *)sender];
    }
}

#pragma mark - Actions -

- (IBAction)openSettingsMenu:(NSButton *)sender {
    NSPoint point = NSMakePoint(0.0, sender.bounds.size.height + 5.0);
    [self.settingsMenu popUpMenuPositioningItem:nil atLocation:point inView:sender];
}

@end
