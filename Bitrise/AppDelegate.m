//
//  AppDelegate.m
//  BitBot
//
//  Created by Deszip on 04/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "AppDelegate.h"

#import "BRStyleSheet.h"
#import "BRLogger.h"
#import "BRAnalytics.h"
#import "BRSyncCommand.h"
#import "BRMainController.h"
#import "BRStandaloneWindowController.h"
#import "BRDependencyContainer.h"
#import "NSPopover+MISSINGBackgroundView.h"

#import "BRCoreController.h"

@interface AppDelegate () <NSPopoverDelegate>

@property (strong, nonatomic) BRCommandFactory *commandFactory;
@property (strong, nonatomic) BRObserver *observer;
@property (strong, nonatomic) BRCoreController *coreController;

@property (strong, nonatomic) BRStandaloneWindowController *mainController;

@end

@implementation AppDelegate

- (instancetype)init {
    if (self = [super init]) {

        [[BRAnalytics analytics] start];
        
    #if DEBUG
        [[BRLogger defaultLogger] setCurrentLogLevel:LL_VERBOSE];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints"];
    #endif

        // Build depencencies
        _dependencyContainer = [BRDependencyContainer new];
        [[self.dependencyContainer appEnvironment] handleAppLaunch];
        self.observer = [self.dependencyContainer commandObserver];
        self.commandFactory = [[BRCommandFactory alloc] initWithAPI:[self.dependencyContainer bitriseAPI]
                                                         syncEngine:[self.dependencyContainer syncEngine]
                                                        environment:[self.dependencyContainer appEnvironment]];
        _coreController = [BRCoreController new];
        [self.coreController establishConnection];
    }

    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Start sync
    BRSyncCommand *syncCommand = [self.commandFactory syncCommand];
    [self.observer startObserving:syncCommand];
    
    // Test core connection
    NSString *request = @"Test";
    NSLog(@"Sending to core: %@", request);
    [self.coreController testConnection:request response:^(NSString *response) {
        NSLog(@"Got response from core: %@", response);
    }];
}

@end
