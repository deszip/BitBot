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
#import "BRContainerBuilder.h"
#import "BRAppsDataSource.h"
#import "BRAccountsViewController.h"

//#import "BRCommandFactory.h"
#import "BRSyncCommand.h"
#import "BRBuildStateInfo.h"
#import "BRSettingsMenuController.h"
#import "BRBuildMenuController.h"
#import "BRFiltersMenuController.h"
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

// Serices
@property (strong, nonatomic) BRAppsDataSource *dataSource;
@property (strong, nonatomic) BRAccountsObserver *accountObserver;

// UI
@property (strong, nonatomic) BRSettingsMenuController *settingsController;
@property (strong, nonatomic) BRBuildMenuController *buildController;
@property (strong, nonatomic) BRFiltersMenuController *filterController;
@property (strong, nonatomic) BRLogsWindowPresenter *logsPresenter;

// Outlets
@property (weak) IBOutlet NSView *topBar;
@property (weak) IBOutlet NSButton *filterButton;
@property (unsafe_unretained) IBOutlet BRAboutTextView *hintView;
@property (weak) IBOutlet NSOutlineView *outlineView;
@property (weak) IBOutlet BREmptyView *emptyView;

// Menus
@property (strong) IBOutlet NSMenu *buildMenu;
@property (strong) IBOutlet NSMenu *settingsMenu;
@property (strong) IBOutlet NSMenu *filterMenu;

@end

@implementation BRMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    // For use in closures
    __weak __typeof(self) weakSelf = self;
    
    // Services
    self.logsPresenter = [[BRLogsWindowPresenter alloc] initWithPresentingController:self];
    self.accountObserver = [self.dependencyContainer accountsObserver];
    [self.accountObserver start:^(BRAccountsState state) {
        [weakSelf handleAccountsState:state];
    }];
    
    // Build menu controller
    self.buildController = [self.dependencyContainer buildMenuController];
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
    [self.dataSource setStateCallback:^(BRBuildsState state) {
        [weakSelf handleBuildsState:state];
    }];
    [self.dataSource bind:self.outlineView];
    
    // Settings menu controller
    self.settingsController = [self.dependencyContainer settingsMenuController];
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
    
    // Filter menu controller
    self.filterController = [self.dependencyContainer filterMenuController];
    [self.filterController bind:self.filterMenu];
    [self.filterController setStateChageCallback:^(BRBuildPredicate *predicate) {
        [weakSelf.dataSource applyPredicate:predicate];
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

- (IBAction)openFiltersMenu:(NSButton *)sender {
    NSPoint point = NSMakePoint(0.0, sender.bounds.size.height + 5.0);
    [self.filterMenu popUpMenuPositioningItem:nil atLocation:point inView:sender];
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
    self.filterButton.enabled = state == BRAccountsStateHasData;
    self.outlineView.hidden = state == BRAccountsStateEmpty;
    self.emptyView.hidden = state == BRAccountsStateHasData;
    
    if (state == BRAccountsStateEmpty) {
        [self.emptyView setViewType:BREmptyViewTypeNoAccounts];
    }
}

- (void)handleBuildsState:(BRBuildsState)state {
    self.outlineView.hidden = state == BRBuildsStateEmpty;
    self.emptyView.hidden = state == BRBuildsStateHasData;
    
    if (state == BRBuildsStateEmpty && self.accountObserver.state == BRAccountsStateHasData) {
        [self.emptyView setViewType:BREmptyViewTypeNoData];
    }
}

@end
