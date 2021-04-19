//
//  BRAccountsViewController.m
//  BitBot
//
//  Created by Deszip on 05/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRAccountsViewController.h"

#import "BRStyleSheet.h"

#import "BRKeyRequestContext.h"
#import "BRKeyInputViewController.h"
#import "BRAccountsMenuController.h"

#import "BTRAccount+CoreDataClass.h"
#import "BRGetAccountCommand.h"
#import "BRRemoveAccountCommand.h"
#import "BRSyncCommand.h"
#import "BRAddBuildTokenCommand.h"

@interface BRAccountsViewController ()

@property (weak) IBOutlet NSTextField *titleField;
@property (weak) IBOutlet NSBox *containerBox;
@property (weak) IBOutlet NSOutlineView *outlineView;
@property (strong) IBOutlet NSMenu *controlMenu;
@property (weak) IBOutlet NSButton *addButton;
@property (weak) IBOutlet NSButton *removeButton;

@property (strong, nonatomic) BRAccountsMenuController *menuController;

@property (strong, nonatomic) BRBitriseAPI *api;
@property (strong, nonatomic) BRStorage *storage;
@property (strong, nonatomic) BRSyncEngine *syncEngine;
@property (strong, nonatomic) BRAccountsDataSource *dataSource;

@end

@implementation BRAccountsViewController

@dynamic dependencyContainer;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.outlineView setBackgroundColor:[BRStyleSheet backgroundColor]];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    
    // UI
    [self.titleField setFont:[BRStyleSheet proximaNova:16.0]];
    [self.titleField setTextColor:[BRStyleSheet secondaryTextColor]];
    [self.containerBox setBorderColor:[BRStyleSheet boxBorderColor]];
    [self.containerBox setFillColor:[NSColor clearColor]];
    [self.addButton setContentTintColor:[BRStyleSheet boxBorderColor]];
    [self.removeButton setContentTintColor:[BRStyleSheet boxBorderColor]];
    
    // Dependencies
    self.api = [self.dependencyContainer bitriseAPI];
    self.storage = [self.dependencyContainer storage];
    self.dataSource = [self.dependencyContainer accountsDataSource];
    self.syncEngine = [self.dependencyContainer syncEngine];
    
    // Menu controller setup
    self.menuController = [[BRAccountsMenuController alloc] initWithAPI:self.api storage:self.storage];
    __weak typeof(self) weakSelf = self;
    [self.menuController setActionCallback:^(BRAppMenuAction action, NSString *slug) {
        if (action == BRAppMenuActionAddKey) {
            [weakSelf performSegueWithIdentifier:@"BRKeyInputViewController" sender:[BRKeyRequestContext appContext:slug]];
        }
        if (action == BRAppMenuActionRemoveAccount) {
            [weakSelf confirmDeletion:^{
                [weakSelf removeAccountWithSlug:slug];
            }];
        }
    }];
    [self.menuController bind:self.controlMenu toOutline:self.outlineView];
    
    // Accounts datasource setup
    [self.dataSource bind:self.outlineView];
    [self.dataSource fetch];
    
    // Outline selection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSelection:) name:NSOutlineViewSelectionDidChangeNotification object:self.outlineView];
    [self.removeButton setEnabled:NO];
}

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationController isKindOfClass:[BRKeyInputViewController class]] &&
        [sender isKindOfClass:[BRKeyRequestContext class]]) {
        BRKeyInputViewController *inputController = (BRKeyInputViewController *)segue.destinationController;
        BRKeyRequestContext *context = (BRKeyRequestContext *)sender;
        
        switch (context.type) {
            case BRKeyRequestContextTypeApp: inputController.inputAnnotation = @"Build trigger token:"; break;
            case BRKeyRequestContextTypeAccount: inputController.inputAnnotation = @"Personal access token:"; break;
            default: break;
        }
        
        [inputController setInputCallback:^(NSString *input) {
            switch (context.type) {
                case BRKeyRequestContextTypeApp: {
                    BRAddBuildTokenCommand *command = [[BRAddBuildTokenCommand alloc] initWithStorage:self.storage appSlug:context.appSlug token:input];
                    [command execute:^(BOOL result, NSError *error) {
                        if (result) {
                            [self.outlineView reloadData];
                        }
                    }];
                    break;
                }
                    
                case BRKeyRequestContextTypeAccount: {
                    BRGetAccountCommand *command = [[BRGetAccountCommand alloc] initWithSyncEngine:self.syncEngine token:input];
                    [command execute:^(BOOL result, NSError *error) {
                        if (result) {
                            [self.outlineView reloadData];
                        }
                    }];
                    break;
                }
                    
                case BRKeyRequestContextTypeUndefined: break;
            }
        }];
    }
}

#pragma mark - Notifications -

- (void)handleSelection:(NSNotification *)notification {
    id selectedItem = [self.outlineView itemAtRow:[self.outlineView selectedRow]];
    if ([selectedItem isKindOfClass:[BTRAccount class]]) {
        [self.removeButton setEnabled:YES];
    } else {
        [self.removeButton setEnabled:NO];
    }
}

#pragma mark - Actions -

- (IBAction)addAccount:(NSButton *)sender {
    [self performSegueWithIdentifier:@"BRKeyInputViewController" sender:[BRKeyRequestContext accountContext]];
}

- (IBAction)removeAccount:(NSButton *)sender {
    id selectedItem = [self.outlineView itemAtRow:[self.outlineView selectedRow]];
    if ([selectedItem isKindOfClass:[BTRAccount class]]) {
        [self confirmDeletion:^{
            [self removeAccountWithSlug:[(BTRAccount *)selectedItem slug]];
        }];
    }
}

- (void)confirmDeletion:(void(^)(void))callback {
    NSAlert *alert = [NSAlert new];
    alert.alertStyle = NSAlertStyleWarning;
    alert.messageText = [NSString stringWithFormat:@"Remove account?"];
    alert.informativeText = [NSString stringWithFormat:@"Really remove account?"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert addButtonWithTitle:@"OK"];
    
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertSecondButtonReturn) {
            BR_SAFE_CALL(callback);
        }
    }];
}

- (void)removeSelectedAccount {
    id selectedItem = [self.outlineView itemAtRow:[self.outlineView clickedRow]];
    if ([selectedItem isKindOfClass:[BTRAccount class]]) {
        BRRemoveAccountCommand *command = [[BRRemoveAccountCommand alloc] initWithAPI:self.api
                                                                              storage:self.storage
                                                                                slug:[(BTRAccount *)selectedItem slug]];
        [command execute:nil];
    }
}

- (void)removeAccountWithSlug:(NSString *)slug {
    BRRemoveAccountCommand *command = [[BRRemoveAccountCommand alloc] initWithAPI:self.api
                                                                          storage:self.storage
                                                                            slug:slug];
    [command execute:nil];
}

@end
