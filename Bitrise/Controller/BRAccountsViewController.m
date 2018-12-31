//
//  BRAccountsViewController.m
//  Bitrise
//
//  Created by Deszip on 05/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BRAccountsViewController.h"

#import "BRKeyRequestContext.h"
#import "BRKeyInputViewController.h"
#import "BRAccountsMenuController.h"

#import "BRAccount+CoreDataClass.h"
#import "BRGetAccountCommand.h"
#import "BRRemoveAccountCommand.h"
#import "BRSyncCommand.h"

@interface BRAccountsViewController ()

@property (weak) IBOutlet NSOutlineView *outlineView;
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
    
    // Dependencies
    self.api = [self.dependencyContainer bitriseAPI];
    self.storage = [self.dependencyContainer storage];
    self.dataSource = [self.dependencyContainer accountsDataSource];
    self.syncEngine = [self.dependencyContainer syncEngine];
    
    // Menu controller setup
    self.menuController = [[BRAccountsMenuController alloc] initWithAPI:self.api storage:self.storage];
    __weak typeof(self) weakSelf = self;
    [self.menuController setNavigationCallback:^(BRAppMenuNavigationAction action, NSString *slug) {
        if (action == BRAppMenuNavigationActionAddKey) {
            [weakSelf performSegueWithIdentifier:@"BRKeyInputViewController" sender:[BRKeyRequestContext appContext:slug]];
        }
    }];
    [self.menuController bind:self.controlMenu toOutline:self.outlineView];
    
    // Accounts datasource setup
    [self.dataSource bind:self.outlineView];
    [self.dataSource fetch];
}

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationController isKindOfClass:[BRKeyInputViewController class]] &&
        [sender isKindOfClass:[BRKeyRequestContext class]]) {
        BRKeyInputViewController *inputController = (BRKeyInputViewController *)segue.destinationController;
        BRKeyRequestContext *context = (BRKeyRequestContext *)sender;
        [inputController setInputCallback:^(NSString *input) {
            switch (context.type) {
                case BRKeyRequestContextTypeApp:
                    NSLog(@"Add key: %@, for app: %@", input, context.appSlug);
                    break;
                    
                case BRKeyRequestContextTypeAccount: {
                    NSLog(@"Add account with token: %@", input);
                    BRGetAccountCommand *command = [[BRGetAccountCommand alloc] initWithSyncEngine:self.syncEngine token:input];
                    [command execute:nil];
                    break;
                }
                    
                case BRKeyRequestContextTypeUndefined: break;
            }
        }];
    }
}

- (IBAction)addAccount:(NSButton *)sender {
    [self performSegueWithIdentifier:@"BRKeyInputViewController" sender:[BRKeyRequestContext accountContext]];
}

- (IBAction)removeAccount:(NSButton *)sender {
    id selectedItem = [self.outlineView itemAtRow:[self.outlineView clickedRow]];
    if ([selectedItem isKindOfClass:[BRAccount class]]) {
        BRRemoveAccountCommand *command = [[BRRemoveAccountCommand alloc] initWithAPI:self.api
                                                                              storage:self.storage
                                                                                token:[(BRAccount *)selectedItem token]];
        [command execute:nil];
    }
}

@end
