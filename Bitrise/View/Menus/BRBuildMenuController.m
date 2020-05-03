//
//  BRBuildMenuController.m
//  BitBot
//
//  Created by Deszip on 25/12/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRBuildMenuController.h"

#import "BRBuild+CoreDataClass.h"
#import "BRBuildInfo.h"
#import "BRAbortCommand.h"
#import "BRRebuildCommand.h"
#import "BRSyncCommand.h"
#import "BRDownloadLogsCommand.h"
#import "BROpenBuildCommand.h"

static const NSUInteger kMenuItemsCount = 5;
typedef NS_ENUM(NSUInteger, BRBuildMenuItem) {
    BRBuildMenuItemRebuild = 0,
    BRBuildMenuItemAbort,
    BRBuildMenuItemShowLog,
    BRBuildMenuItemDownload,
    BRBuildMenuItemOpenBuild
};

@interface BRBuildMenuController ()

@property (strong, nonatomic) BRBitriseAPI *api;
@property (strong, nonatomic) BRSyncEngine *syncEngine;
@property (strong, nonatomic) BRLogObserver *logObserver;
@property (strong, nonatomic) BREnvironment *environment;

@property (weak, nonatomic) NSOutlineView *outlineView;
@property (weak, nonatomic) NSView *triggeredView;

@end

@implementation BRBuildMenuController

- (instancetype)initWithAPI:(BRBitriseAPI *)api
                 syncEngine:(BRSyncEngine *)syncEngine
                logObserver:(BRLogObserver *)logObserver
                environment:(BREnvironment *)environment {
    if (self = [super init]) {
        _api = api;
        _syncEngine = syncEngine;
        _logObserver = logObserver;
        _environment = environment;
    }
    
    return self;
}

- (void)setMenu:(NSMenu *)menu {
    _menu = menu;
    
    if (self.menu.itemArray.count == kMenuItemsCount) {
        [self.menu.itemArray enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
            [item setTag:idx];
            [item setTarget:self];
        }];
        
        [self.menu.itemArray[BRBuildMenuItemRebuild]   setAction:@selector(rebuild)];
        [self.menu.itemArray[BRBuildMenuItemAbort]     setAction:@selector(abort)];
        [self.menu.itemArray[BRBuildMenuItemShowLog]   setAction:@selector(showLog)];
        [self.menu.itemArray[BRBuildMenuItemDownload]  setAction:@selector(downloadLog)];
        [self.menu.itemArray[BRBuildMenuItemOpenBuild] setAction:@selector(openBuild)];
    }
}

- (void)bindToOutline:(NSOutlineView *)outline {
    self.outlineView = outline;
    self.outlineView.menu = self.menu;
}

- (void)bindToButton:(NSButton *)button {
    [button setTarget:self];
    [button setAction:@selector(showMenu:)];
}

#pragma mark - Presentation -

- (void)showMenu:(NSButton *)button {
    self.triggeredView = button;
    NSEvent *event = [[NSApplication sharedApplication] currentEvent];
    [NSMenu popUpContextMenu:self.menu withEvent:event forView:button];
}

#pragma mark - Actions -

- (void)rebuild {
    BRBuild *build = [self selectedBuild];
    if (build) {
        BRRebuildCommand *command = [[BRRebuildCommand alloc] initWithAPI:self.api build:build];
        [command execute:^(BOOL result, NSError *error) {
            if (result) {
                BRSyncCommand *syncCommand = [[BRSyncCommand alloc] initSyncEngine:self.syncEngine
                                                                       logObserver:self.logObserver
                                                                       environment:self.environment];
                [syncCommand execute:nil];
            }
        }];
    }
}

- (void)abort {
    BRBuild *build = [self selectedBuild];
    if (build) {
        BRAbortCommand *command = [[BRAbortCommand alloc] initWithAPI:self.api build:build];
        [command execute:^(BOOL result, NSError *error) {
            if (result) {
                BRSyncCommand *syncCommand = [[BRSyncCommand alloc] initSyncEngine:self.syncEngine
                                                                       logObserver:self.logObserver
                                                                       environment:self.environment];
                [syncCommand execute:nil];
            }
        }];
    }
}

- (void)showLog {
    BRBuild *build = [self selectedBuild];
    if (build) {
        BRBuildInfo *buildInfo = [[BRBuildInfo alloc] initWithBuild:build];
        BR_SAFE_CALL(self.actionCallback, BRBuildMenuActionShowLog, buildInfo);
    }
}

- (void)downloadLog {
    BRBuild *build = [self selectedBuild];
    if (build) {
        BRDownloadLogsCommand *command = [[BRDownloadLogsCommand alloc] initWithBuildSlug:build.slug];
        [command execute:nil];
    }
}

- (void)openBuild {
    BRBuild *build = [self selectedBuild];
    if (build) {
        BROpenBuildCommand *command = [[BROpenBuildCommand alloc] initWithBuildSlug:build.slug];
        [command execute:nil];
    }
}

#pragma mark - NSMenuItemValidation -

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    BRBuild *build = [self selectedBuild];
    BRBuildInfo *buildInfo = [[BRBuildInfo alloc] initWithBuild:build];
    return [self menuItem:menuItem isValidFor:buildInfo];
}

- (BOOL)menuItem:(NSMenuItem *)menuItem isValidFor:(BRBuildInfo *)buildInfo {
    BOOL buildInProgress = buildInfo.stateInfo.state == BRBuildStateInProgress;
    BOOL buildCouldBeAborted = buildInfo.stateInfo.state == BRBuildStateInProgress ||
    buildInfo.stateInfo.state == BRBuildStateHold;
    BOOL buildLogAvailable = buildInfo.stateInfo.state != BRBuildStateHold && !buildInProgress;
    
    switch (menuItem.tag) {
        case BRBuildMenuItemRebuild: return !buildInProgress;
        case BRBuildMenuItemAbort: return buildCouldBeAborted;
        case BRBuildMenuItemShowLog: return buildLogAvailable;
        case BRBuildMenuItemDownload: return buildLogAvailable;
        case BRBuildMenuItemOpenBuild: return YES;
        default: return NO;
    }
}

#pragma mark - Build provider -

- (BRBuild *)selectedBuild {
    return BR_SAFE_CALL(self.buildProvider, self.triggeredView);
}

@end
