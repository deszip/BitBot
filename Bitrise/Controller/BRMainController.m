//
//  BRMainController.m
//  BitBot
//
//  Created by Deszip on 04/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRMainController.h"

#import "BRStyleSheet.h"

#import "BREmptyView.h"
#import "BRAboutTextView.h"
#import "BRPersistentContainerBuilder.h"
#import "BRAppsDataSource.h"
#import "BRAccountsViewController.h"

#import "BRCommandFactory.h"
#import "BRSyncCommand.h"
#import "BRBuildStateInfo.h"
#import "BRSettingsMenuController.h"
#import "BRBuildMenuController.h"
#import "BRLogsTextViewController.h"
#import "BRSegue.h"
#import "BRLogsWindowPresenter.h"
#import "BRAccountsObserver.h"

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
@property (strong, nonatomic) BRLauncher *appLauncher;
@property (strong, nonatomic) BRCommandFactory *commandFactory;

@property (strong, nonatomic) BRAppsDataSource *dataSource;
@property (strong, nonatomic) BRSettingsMenuController *settingsController;
@property (strong, nonatomic) BRBuildMenuController *buildController;
@property (strong, nonatomic) BRLogsWindowPresenter *logsPresenter;

@property (strong, nonatomic) BRAccountsObserver *accountObserver;

@property (weak) IBOutlet NSView *topBar;

@property (unsafe_unretained) IBOutlet BRAboutTextView *hintView;
@property (weak) IBOutlet NSOutlineView *outlineView;
@property (weak) IBOutlet BREmptyView *emptyView;
@property (strong) IBOutlet NSMenu *buildMenu;
@property (strong) IBOutlet NSMenu *settingsMenu;

@end

@implementation BRMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    // For use in closures
    __weak __typeof(self) weakSelf = self;
    
    // Services
    self.logsPresenter = [[BRLogsWindowPresenter alloc] initWithPresentingController:self];
    self.syncEngine = [self.dependencyContainer syncEngine];
    self.environment = [self.dependencyContainer appEnvironment];
    self.appLauncher = [self.dependencyContainer appLauncher];
    self.accountObserver = [self.dependencyContainer accountsObserver];
    [self.accountObserver startStateObserving:^(BRAccountsState state) {
        [weakSelf handleAccountsState:state];
    }];
    
    // Build menu controller
    self.commandFactory = [[BRCommandFactory alloc] initWithAPI:[self.dependencyContainer bitriseAPI]
                                                     syncEngine:self.syncEngine
                                                    notificationsDispatcher:[self.dependencyContainer notificationDispatcher]];
    self.buildController = [[BRBuildMenuController alloc] initWithCommandFactory:self.commandFactory];
    self.buildController.menu = self.buildMenu;
    self.buildController.buildProvider = ^BRBuild* (NSView *targetView) {
        id selectedItem = [weakSelf.outlineView itemAtRow:[weakSelf.outlineView clickedRow]];
        if (!selectedItem) {
            selectedItem = [weakSelf.outlineView itemAtRow:[weakSelf.outlineView rowForView:targetView]];
        }
        if ([selectedItem isKindOfClass:[BRBuild class]]) {
            return selectedItem;
        }
        return nil;
    };
    [self.buildController bindToOutline:self.outlineView];
    [self.buildController setActionCallback:^(BRBuildMenuAction action, BRBuildInfo *buildInfo) {
        if (action == BRBuildMenuActionShowLog) {
            [weakSelf.logsPresenter presentLogs:buildInfo];
        }
    }];
    
    // Builds data source
    BRCellBuilder *cellBuilder = [[BRCellBuilder alloc] initWithMenuController:self.buildController];
    self.dataSource = [self.dependencyContainer appsDataSourceWithCellBuilder:cellBuilder];
    [self.dataSource bind:self.outlineView];
    
    // Settings menu controller
    self.settingsController = [[BRSettingsMenuController alloc]
                               initWithEnvironment:self.environment
                               appLauncher:[self.dependencyContainer appLauncher]
                               notificationsDispatcher:[self.dependencyContainer notificationDispatcher]];
    [self.settingsController bind:self.settingsMenu];
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
    
    // Empty view callback
    [self.emptyView setCallback:^{
        [weakSelf performSegueWithIdentifier:kAccountWindowSegue sender:weakSelf];
    }];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    [self.outlineView reloadData];
    [self.dataSource fetch];
}

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];

    if ([segue.identifier isEqualToString:kLogWindowSegue]) {
        BRLogsTextViewController *logController = (BRLogsTextViewController *)[(NSWindowController *)segue.destinationController contentViewController];
        [logController setBuildInfo:(BRBuildInfo *)sender];
    }
    
    [[(NSWindowController *)segue.destinationController window] makeKeyAndOrderFront:self];
    [NSApplication.sharedApplication activateIgnoringOtherApps:YES];
}

#pragma mark - Actions -

- (IBAction)openStandaloneWindow:(NSButton *)sender {
    //[self performSegueWithIdentifier:kStandaloneWindowSegue sender:self];
    [self.appLauncher launchMainApp];
}

- (IBAction)openSettingsMenu:(NSButton *)sender {
    NSPoint point = NSMakePoint(0.0, sender.bounds.size.height + 5.0);
    [self.settingsMenu popUpMenuPositioningItem:nil atLocation:point inView:sender];
}

#pragma mark - UI setup -

- (void)setupUI {
    [self.topBar setWantsLayer:YES];
    [self.topBar.layer setBackgroundColor:[BRStyleSheet backgroundColor].CGColor];
    
    [self.hintView setAutomaticLinkDetectionEnabled:YES];
    [self.hintView setFont:[BRStyleSheet aboutTextFont]];
    
    [self.outlineView setBackgroundColor:[BRStyleSheet backgroundColor]];
}

- (void)handleAccountsState:(BRAccountsState)state {
    self.outlineView.hidden = state == BRAccountsStateEmpty;
    self.emptyView.hidden = state == BRAccountsStateHasData;
}

@end
