//
//  BRSettingsViewController.m
//  BitBot
//
//  Created by Deszip on 19.03.2022.
//  Copyright © 2022 Bitrise. All rights reserved.
//

#import "BRSettingsViewController.h"

#import "BRLauncher.h"

@interface BRSettingsViewController ()

@property (weak) IBOutlet NSButton *menuAppCheckbox;

@property (strong, nonatomic) BRLauncher *launcher;

@end

@implementation BRSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.launcher = [self.dependencyContainer appLauncher];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    
    [self updateMenuAppCheckboxState];
}

- (IBAction)toggleMenuApp:(NSButton *)sender {
    if (sender.state == NSControlStateValueOn && [self.launcher menuAppIsRunning] == NO) {
        [self.launcher launchMenuApp];
    }
    
    if (sender.state == NSControlStateValueOff) {
        [self.launcher killMenuApp];
    }
}

#pragma mark - UI state

- (void)updateMenuAppCheckboxState {
    [self.menuAppCheckbox setState:[self.launcher menuAppIsRunning] ? NSControlStateValueOn : NSControlStateValueOff];
}

@end
