//
//  BRStandaloneWindowController.m
//  BitBot
//
//  Created by Deszip on 21.11.2021.
//  Copyright © 2021 Bitrise. All rights reserved.
//

#import "BRStandaloneWindowController.h"

#import "AppDelegate.h"
#import "BRSplitViewController.h"
#import "BRTabViewController.h"

NSNotificationName kStandaloneTabSelectedNotification = @"kStandaloneTabSelectedNotification";

@interface BRStandaloneWindowController ()

@property (strong, nonatomic) NSNotificationCenter *notificationCenter;

@end

@implementation BRStandaloneWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
//    self.dependencyContainer = [(AppDelegate *)[[NSApplication sharedApplication] delegate]
}

- (void)didSetContainer {
    self.notificationCenter = [self.dependencyContainer notificationCenter];
}

- (IBAction)displayInfo:(id)sender {
    [self notifyTabSwitchTo:BRStandaloneTabInfo];
}

- (IBAction)displaySchedule:(id)sender {
    [self notifyTabSwitchTo:BRStandaloneTabSchedule];
}

- (IBAction)displayStats:(id)sender {
    [self notifyTabSwitchTo:BRStandaloneTabStats];
}

- (IBAction)displaySettings:(id)sender {
    [self notifyTabSwitchTo:BRStandaloneTabSettings];
}

#pragma mark - Private

- (void)notifyTabSwitchTo:(BRStandaloneTab)tabIndex {
    [self.notificationCenter postNotificationName:kStandaloneTabSelectedNotification
                                           object:self
                                         userInfo:@{@"TabIndex" : @(tabIndex)}];
}

@end
