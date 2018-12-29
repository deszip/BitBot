//
//  BRAccountsViewController.m
//  Bitrise
//
//  Created by Deszip on 05/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BRAccountsViewController.h"

#import "BRAccountsMenuController.h"

#import "BRAccount+CoreDataClass.h"
#import "BRGetAccountCommand.h"
#import "BRRemoveAccountCommand.h"
#import "BRSyncCommand.h"

@interface BRAccountsViewController ()

@property (weak) IBOutlet NSOutlineView *outlineView;
@property (weak) IBOutlet NSTextField *keyField;
@property (strong) IBOutlet NSMenu *controlMenu;

@property (strong, nonatomic) BRAccountsMenuController *menuController;

@property (strong, nonatomic) BRBitriseAPI *api;
@property (strong, nonatomic) BRStorage *storage;
@property (strong, nonatomic) BRSyncEngine *syncEngine;
@property (strong, nonatomic) BRAccountsDataSource *dataSource;

@end

@implementation BRAccountsViewController

@dynamic dependencyContainer;

- (void)viewDidAppear {
    [super viewDidAppear];
    
    self.menuController = [BRAccountsMenuController new];
    [self.menuController bind:self.controlMenu toOutline:self.outlineView];
    
    self.api = [self.dependencyContainer bitriseAPI];
    self.storage = [self.dependencyContainer storage];
    self.syncEngine = [self.dependencyContainer syncEngine];
    self.dataSource = [self.dependencyContainer accountsDataSource];
    [self.dataSource bind:self.outlineView];
    [self.dataSource fetch];
}

- (IBAction)saveKey:(NSButton *)sender {
    BRGetAccountCommand *command = [[BRGetAccountCommand alloc] initWithSyncEngine:self.syncEngine token:self.keyField.stringValue];
    [command execute:nil];
}

- (IBAction)removeKey:(NSButton *)sender {
    BRAccount *selectedAccount = [self.outlineView itemAtRow:[self.outlineView rowForView:sender]];
    BRRemoveAccountCommand *command = [[BRRemoveAccountCommand alloc] initWithAPI:self.api
                                                                          storage:self.storage
                                                                            token:selectedAccount.token];
    [command execute:nil];
}

@end
