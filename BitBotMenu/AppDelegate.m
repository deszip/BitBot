//
//  AppDelegate.m
//  BitBotMenu
//
//  Created by Deszip on 13.03.2022.
//  Copyright © 2022 Bitrise. All rights reserved.
//

#import "AppDelegate.h"

#import "BRStyleSheet.h"
#import "BRLogger.h"
#import "BRAnalytics.h"
#import "BRSyncCommand.h"
#import "BRMainController.h"
#import "NSPopover+MISSINGBackgroundView.h"


@interface AppDelegate () <NSPopoverDelegate>

@property (strong, nonatomic) BRCommandFactory *commandFactory;
@property (strong, nonatomic) BRObserver *observer;

@property (strong, nonatomic) BRMainController *mainController;
@property (strong, nonatomic) BRMainController *detachableMainController;

@property (strong, nonatomic) NSWindowController *detachableWindowController;
@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) NSPopover *popover;

@end

@implementation AppDelegate

- (instancetype)init {
    if (self = [super init]) {
        
#if DEBUG
        [[BRLogger defaultLogger] setCurrentLogLevel:LL_VERBOSE];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints"];
#endif
        
        _dependencyContainer = [BRDependencyContainer new];
        [[_dependencyContainer appEnvironment] handleAppLaunch];
        _observer = [_dependencyContainer commandObserver];
        
        _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
        _popover = [[NSPopover alloc] init];
        _popover.backgroundColor = [BRStyleSheet backgroundColor];
        _popover.delegate = self;
        
        NSStoryboard *mainStoryboard = [NSStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        
        _mainController = [mainStoryboard instantiateControllerWithIdentifier:@"BRMainController"];
        _detachableMainController = [mainStoryboard instantiateControllerWithIdentifier:@"BRMainController"];
        
        _detachableWindowController = [mainStoryboard instantiateControllerWithIdentifier:@"BRMainWindow"];
        [_detachableWindowController.window setLevel:NSFloatingWindowLevel];
        [_detachableWindowController.window setTitleVisibility:NSWindowTitleHidden];
    }
    
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[BRAnalytics analytics] start];
    
    self.commandFactory = [[BRCommandFactory alloc] initWithAPI:[self.dependencyContainer bitriseAPI]
                                                     syncEngine:[self.dependencyContainer syncEngine]
                                                    environment:[self.dependencyContainer appEnvironment]];
    
    // Start sync
    BRSyncCommand *syncCommand = [self.commandFactory syncCommand];
    [self.observer startObserving:syncCommand];
    
    // Build status item
    NSImage *image = [NSImage imageNamed:@"bitrise-bot-icon"];
    self.statusItem.button.image = image;
    self.statusItem.button.imageScaling = NSImageScaleProportionallyDown;
    self.statusItem.button.alternateImage = image;
    [self.statusItem.button setAction:@selector(togglePopover:)];
    [(NSButtonCell *)self.statusItem.button.cell setHighlightsBy:NSNoCellMask];
    
    // Build popover
    self.popover.contentViewController = self.mainController;
    self.popover.behavior = NSPopoverBehaviorTransient;
}

#pragma mark - Actions -

- (void)togglePopover:(NSStatusBarButton *)sender {
    if (self.popover.shown) {
        [self.popover performClose:self];
    } else {
        if (self.detachableWindowController.window.isVisible) {
            [self.detachableWindowController.window makeKeyAndOrderFront:self];
        } else {
            [self.popover showRelativeToRect:sender.bounds ofView:sender preferredEdge:NSRectEdgeMinY];
        }
    }
}

#pragma mark - NSPopoverDelegate -

- (BOOL)popoverShouldDetach:(NSPopover *)popover {
    return YES;
}

- (NSWindow *)detachableWindowForPopover:(NSPopover *)popover {
    self.detachableWindowController.window.contentViewController = self.detachableMainController;
    [self.detachableWindowController.window setMovableByWindowBackground:YES];
    
    return self.detachableWindowController.window;
}


@end
