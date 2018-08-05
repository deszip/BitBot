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
@property (strong, nonatomic) BRObserver *observer;
@property (strong, nonatomic) BRAppsDataSource *dataSource;

@property (weak) IBOutlet NSOutlineView *outlineView;
@property (strong) IBOutlet NSMenu *buildMenu;

@end

@implementation BRMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.api = [self.dependencyContainer bitriseAPI];
    self.storage = [self.dependencyContainer storage];
    self.observer = [self.dependencyContainer commandObserver];
    self.dataSource = [self.dependencyContainer appsDataSource];
    [self.dataSource bind:self.outlineView];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    
    [self.dataSource fetch];
    
    BRSyncCommand *syncCommand = [[BRSyncCommand alloc] initWithAPI:self.api storage:self.storage];
    [syncCommand execute:nil];
    
    [self.observer startObserving:syncCommand];
}

#pragma mark - NSMenuDelegate -

- (void)menuWillOpen:(NSMenu *)menu {
    id selectedItem = [self.outlineView itemAtRow:[self.outlineView clickedRow]];
    if (![selectedItem isKindOfClass:[BRBuild class]]) {
        [menu cancelTrackingWithoutAnimation];
    }
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    id selectedItem = [self.outlineView itemAtRow:[self.outlineView clickedRow]];
    if ([selectedItem isKindOfClass:[BRBuild class]]) {
        BRBuildStateInfo *stateInfo = [[BRBuildStateInfo alloc] initWithBuild:selectedItem];
        BOOL buildInProgress = stateInfo.state == BRBuildStateInProgress;
        switch (menuItem.tag) {
            case BRBuildMenuItemRebuild: return !buildInProgress;
            case BRBuildMenuItemAbort: return buildInProgress;
            case BRBuildMenuItemDownload: return !buildInProgress;
            case BRBuildMenuItemOpenBuild: return buildInProgress;
            default: return NO;
        }
    }
    
    return NO;
}

#pragma mark - Actions -

- (IBAction)presentationChanged:(NSSegmentedControl *)sender {
    switch (sender.selectedSegment) {
        case 0: [self.dataSource setPresentationStyle:BRPresentationStyleList]; break;
        case 1: [self.dataSource setPresentationStyle:BRPresentationStyleTree]; break;
    }
}

- (IBAction)rebuild:(id)sender {
    //id selectedItem = [self.outlineView itemAtRow:[self.outlineView clickedRow]];
}

- (IBAction)abort:(id)sender {
    //id selectedItem = [self.outlineView itemAtRow:[self.outlineView clickedRow]];
}

- (IBAction)downloadLog:(id)sender {
    //id selectedItem = [self.outlineView itemAtRow:[self.outlineView clickedRow]];
}

- (IBAction)openBuild:(id)sender {
    id selectedItem = [self.outlineView itemAtRow:[self.outlineView clickedRow]];
    if ([selectedItem isKindOfClass:[BRBuild class]]) {
        NSString *downloadPath = [NSString stringWithFormat:@"https://app.bitrise.io/api/build/%@/logs.json?&download=log", [(BRBuild *)selectedItem slug]];
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:downloadPath]];
    }
}

@end
