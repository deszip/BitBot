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

static const NSUInteger kMenuItemsCount = 6;
typedef NS_ENUM(NSUInteger, BRBuildMenuItem) {
    BRBuildMenuItemRebuild = 0,
    BRBuildMenuItemAbort,
    BRBuildMenuItemShowLog,
    BRBuildMenuItemDownload,
    BRBuildMenuItemOpenBuild,
    BRBuildMenuItemOpenArtefacts
};

@interface BRBuildMenuController () <NSMenuItemValidation>

@property (strong, nonatomic) BRCommandFactory *commandFactory;

@property (weak, nonatomic) NSOutlineView *outlineView;
@property (weak, nonatomic) NSView *triggeredView;

@end

@implementation BRBuildMenuController

- (instancetype)initWithCommandFactory:(BRCommandFactory *)commandFactory {
    if (self = [super init]) {
        _commandFactory = commandFactory;
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
        [self.menu.itemArray[BRBuildMenuItemOpenBuild] setAction:@selector(openBuildLogs)];
        [self.menu.itemArray[BRBuildMenuItemOpenArtefacts] setAction:@selector(openBuildArtefacts)];
    }
}

- (void)bindToOutline:(NSOutlineView *)outline {
    self.outlineView = outline;
    self.outlineView.menu = self.menu;
    [self.outlineView setTarget:self];
    self.outlineView.doubleAction = @selector(handleDoubleClick:);
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

- (void)handleDoubleClick:(id)sender {
    [self openBuildLogs];
}

- (void)rebuild {
    BRBuild *build = [self selectedBuild];
    if (build) {
        BRRebuildCommand *command = [self.commandFactory rebuildCommand:build];
        [command execute: ^(BOOL result, NSError *error) {
            if (result) {
                BRSyncCommand *syncCommand = [self.commandFactory syncCommand];
                [syncCommand execute:nil];
            }
        }];
    }
}

- (void)abort {
    BRBuild *build = [self selectedBuild];
    if (build) {
        BRAbortCommand *command = [self.commandFactory abortCommand:build];
        [command execute:^(BOOL result, NSError *error) {
            if (result) {
                BRSyncCommand *syncCommand = [self.commandFactory syncCommand];
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
        BRDownloadLogsCommand *command = [self.commandFactory logsCommand:build.slug];
        [command execute:nil];
    }
}

- (void)openBuildLogs {
    [self openBuildTab:BRBuildPageTabLogs];
}

- (void)openBuildArtefacts {
    [self openBuildTab:BRBuildPageTabArtefacts];
}

- (void)openBuildTab:(BRBuildPageTab)tab {
    BRBuild *build = [self selectedBuild];
    if (build) {
        BROpenBuildCommand *command = [self.commandFactory openCommand:build.slug tab:tab];
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
    BOOL buildArtefactsAvailable = buildLogAvailable;
    
    switch (menuItem.tag) {
        case BRBuildMenuItemRebuild: return !buildInProgress;
        case BRBuildMenuItemAbort: return buildCouldBeAborted;
        case BRBuildMenuItemShowLog: return buildLogAvailable;
        case BRBuildMenuItemDownload: return buildLogAvailable;
        case BRBuildMenuItemOpenBuild: return YES;
        case BRBuildMenuItemOpenArtefacts: return buildArtefactsAvailable;
        default: return NO;
    }
}

#pragma mark - Build provider -

- (BRBuild *)selectedBuild {
    return BR_SAFE_CALL(self.buildProvider, self.triggeredView);
}

@end
