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

@property (strong, nonatomic) NSPersistentContainer *container;
@property (strong, nonatomic) BRAppsDataSource *dataSource;

@property (weak) IBOutlet NSOutlineView *outlineView;

@end

@implementation BRMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BRContainerBuilder *builder = [BRContainerBuilder new];
    self.container = [builder buildContainer];
    
    self.dataSource = [[BRAppsDataSource alloc] initWithContainer:self.container outline:self.outlineView];

    //[self.dataSource buildStubs];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    [self.dataSource fetch];
}

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"BRAccountsViewController"]) {
        [(BRAccountsViewController *)segue.destinationController setContainer:self.container];
    }
}

@end
