//
//  BRSettingsViewController.m
//  BitBot
//
//  Created by Deszip on 19.03.2022.
//  Copyright © 2022 Bitrise. All rights reserved.
//

#import "BRSettingsViewController.h"

@interface BRSettingsViewController ()

@end

@implementation BRSettingsViewController

- (IBAction)toggleMenuApp:(id)sender {
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *menuAppPath = [[mainBundle bundlePath] stringByAppendingString:@"/Contents/Resources/BitBotMenu.app"];
    NSURL *menuAppURL = [NSURL fileURLWithPath:menuAppPath];
    
    [[NSWorkspace sharedWorkspace] openApplicationAtURL:menuAppURL
                                          configuration:[NSWorkspaceOpenConfiguration configuration]
                                      completionHandler:^(NSRunningApplication * _Nullable app, NSError * _Nullable error) {
            NSLog(@"App: %@, error: %@", app, error);
    }];
}

@end
