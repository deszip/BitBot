//
//  BRLauncher.m
//  Bitrise
//
//  Created by Deszip on 26.03.2022.
//  Copyright © 2022 Bitrise. All rights reserved.
//

#import "BRLauncher.h"

#import <AppKit/AppKit.h>

static NSString * const kMainAppBundleID = @"com.bitbot";
static NSString * const kMenuAppBundleID = @"com.bitbot.bitbotMenu";

@implementation BRLauncher

- (BOOL)menuAppIsRunning {
    return [self appIsRunning:kMenuAppBundleID];
}

- (void)launchMenuApp {
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSURL *menuAppURL = [[mainBundle bundleURL] URLByAppendingPathComponent:@"/Contents/Resources/BitBotMenu.app"];
    
    [[NSWorkspace sharedWorkspace] openApplicationAtURL:menuAppURL
                                          configuration:[NSWorkspaceOpenConfiguration configuration]
                                      completionHandler:^(NSRunningApplication *app, NSError *error) {
            NSLog(@"App: %@, error: %@", app, error);
    }];
}

- (void)killMenuApp {
    [[self runningApp:kMenuAppBundleID] forceTerminate];
}

- (BOOL)mainAppIsRunning {
    return [self appIsRunning:kMainAppBundleID];
}

- (void)launchMainApp {
    if ([self mainAppIsRunning]) {
        NSRunningApplication *mainApp = [self runningApp:kMainAppBundleID];
        [mainApp unhide];
        [mainApp activateWithOptions:NSApplicationActivateIgnoringOtherApps];
        return;
    }
    
    NSURL *mainBundleURL = [[NSBundle mainBundle] bundleURL];
    
    // First check if main app bundle is in the same directory
    // Could be if we run menu app directly via Xcode
    NSURL *mainAppURL = [[mainBundleURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:@"BitBot.app"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[mainAppURL path]]) {
        mainAppURL = [[[[mainBundleURL
                         URLByDeletingLastPathComponent]
                        URLByDeletingLastPathComponent]
                       URLByDeletingLastPathComponent]
                      URLByDeletingLastPathComponent];
    }

    [[NSWorkspace sharedWorkspace] openApplicationAtURL:mainAppURL
                                          configuration:[NSWorkspaceOpenConfiguration configuration]
                                      completionHandler:^(NSRunningApplication *app, NSError *error) {
            NSLog(@"App: %@, error: %@", app, error);
    }];
}

- (void)killMainApp {
    [[self runningApp:kMainAppBundleID] terminate];
}

- (void)quit {
    [NSApp terminate:self];
}

#pragma mark - Private utils

- (BOOL)appIsRunning:(NSString *)bundleID {
    return [self runningApp:bundleID] != nil;
}

- (NSRunningApplication *)runningApp:(NSString *)bundleID {
    __block NSRunningApplication *app = nil;
    [[[NSWorkspace sharedWorkspace] runningApplications] enumerateObjectsUsingBlock:^(NSRunningApplication *nextApp, NSUInteger idx, BOOL *stop) {
        if ([nextApp.bundleIdentifier isEqualToString:bundleID]) {
            app = nextApp;
            *stop = YES;
        }
    }];
    
    return app;
}
 
@end
