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

@interface AppDelegate () <NSPopoverDelegate>

@property (strong, nonatomic) BRCommandFactory *commandFactory;
@property (strong, nonatomic) BRObserver *observer;

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
        [[_dependencyContainer appEnvironment] handleAppLaunch:^{
            [[self.dependencyContainer notificationDispatcher] enableNotifications];
            
        }];
        self.observer = [self.dependencyContainer commandObserver];
        self.commandFactory = [[BRCommandFactory alloc] initWithAPI:[self.dependencyContainer bitriseAPI]
                                                         syncEngine:[self.dependencyContainer syncEngine]            
                                            notificationsDispatcher:[self.dependencyContainer notificationDispatcher]];    }

    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Start sync
    BRSyncCommand *syncCommand = [self.commandFactory syncCommand];
    [self.observer startObserving:syncCommand];
}

@end
