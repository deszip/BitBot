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

@interface BRMainController ()

@property (strong, nonatomic) BRBitriseAPI *api;
@property (strong, nonatomic) BRStorage *storage;
@property (strong, nonatomic) BRAppsDataSource *dataSource;
@property (weak) IBOutlet NSOutlineView *outlineView;

@end

@implementation BRMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.api = [self.dependencyContainer bitriseAPI];
    self.storage = [self.dependencyContainer storage];
    self.dataSource = [self.dependencyContainer appsDataSource];
    [self.dataSource bind:self.outlineView];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    
    [self.dataSource fetch];
    
    BRSyncCommand *syncCommand = [[BRSyncCommand alloc] initWithAPI:self.api storage:self.storage];
    [syncCommand execute];
}

- (IBAction)presentationChanged:(NSSegmentedControl *)sender {
    switch (sender.selectedSegment) {
        case 0: [self.dataSource setPresentationStyle:BRPresentationStyleList]; break;
        case 1: [self.dataSource setPresentationStyle:BRPresentationStyleTree]; break;
    }
}

@end
