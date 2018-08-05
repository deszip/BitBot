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
    [self.outlineView deselectAll:nil];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    //id selectedItem = [self.outlineView itemAtRow:[self.outlineView clickedRow]];
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

@end
