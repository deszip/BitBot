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

@interface BRMainController ()

@property (strong, nonatomic) BRAppsDataSource *dataSource;
@property (weak) IBOutlet NSOutlineView *outlineView;

@end

@implementation BRMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = [self.dependencyContainer appsDataSourceFor:self.outlineView];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    [self.dataSource fetch];
}

@end
