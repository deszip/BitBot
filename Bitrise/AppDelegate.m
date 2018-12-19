//
//  AppDelegate.m
//  Bitrise
//
//  Created by Deszip on 04/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "AppDelegate.h"

#import "BRSyncCommand.h"
#import "BRMainController.h"
#import "BRDependencyContainer.h"

@interface AppDelegate () <NSPopoverDelegate>

@property (strong, nonatomic) BRDependencyContainer *dependencyContainer;
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
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints"];
#endif
        
        _dependencyContainer = [BRDependencyContainer new];
        _observer = [_dependencyContainer commandObserver];
        
        _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
        _popover = [[NSPopover alloc] init];
        _popover.delegate = self;
        
        _mainController = [[NSStoryboard mainStoryboard] instantiateControllerWithIdentifier:@"BRMainController"];
        _mainController.dependencyContainer = _dependencyContainer;
        _detachableMainController = [[NSStoryboard mainStoryboard] instantiateControllerWithIdentifier:@"BRMainController"];
        _detachableMainController.dependencyContainer = _dependencyContainer;
        
        _detachableWindowController = [[NSStoryboard mainStoryboard] instantiateControllerWithIdentifier:@"BRMainWindow"];
        [_detachableWindowController.window setLevel:NSStatusWindowLevel];
    }
    
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Start sync
    BRSyncCommand *syncCommand = [[BRSyncCommand alloc] initSyncEngine:[self.dependencyContainer syncEngine]];
    [self.observer startObserving:syncCommand];
    
    // Build status item
    NSImage *image = [NSImage imageNamed:@"bitrise-logo"];
    self.statusItem.button.image = image;
    self.statusItem.button.imageScaling = NSImageScaleProportionallyDown;
    self.statusItem.button.alternateImage = image;
    [self.statusItem.button setAction:@selector(togglePopover:)];
    
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
