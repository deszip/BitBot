//
//  BRBuildMenuController.m
//  Bitrise
//
//  Created by Deszip on 25/12/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BRBuildMenuController.h"

#import "BRBuild+CoreDataClass.h"
#import "BRBuildInfo.h"
#import "BRAbortCommand.h"
#import "BRRebuildCommand.h"
#import "BRSyncCommand.h"

static const NSUInteger kMenuItemsCount = 4;
typedef NS_ENUM(NSUInteger, BRBuildMenuItem) {
    BRBuildMenuItemRebuild = 0,
    BRBuildMenuItemAbort,
    BRBuildMenuItemDownload,
    BRBuildMenuItemOpenBuild
};

@interface BRBuildMenuController ()

@property (strong, nonatomic) BRBitriseAPI *api;
@property (strong, nonatomic) BRSyncEngine *syncEngine;
@property (strong, nonatomic) BREnvironment *environment;

@property (weak, nonatomic) NSMenu *menu;
@property (weak, nonatomic) NSOutlineView *outlineView;

@end

@implementation BRBuildMenuController

- (instancetype)initWithAPI:(BRBitriseAPI *)api syncEngine:(BRSyncEngine *)syncEngine environment:(BREnvironment *)environment {
    if (self = [super init]) {
        _api = api;
        _syncEngine = syncEngine;
        _environment = environment;
    }
    
    return self;
}

- (void)bind:(NSMenu *)menu toOutline:(NSOutlineView *)outline {
    self.menu = menu;
    self.outlineView = outline;
    self.outlineView.menu = self.menu;
    
    if (self.menu.itemArray.count == kMenuItemsCount) {
        [self.menu.itemArray enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
            [item setTag:idx];
            [item setTarget:self];
        }];
        
        [self.menu.itemArray[BRBuildMenuItemRebuild]   setAction:@selector(rebuild)];
        [self.menu.itemArray[BRBuildMenuItemAbort]     setAction:@selector(abort)];
        [self.menu.itemArray[BRBuildMenuItemDownload]  setAction:@selector(downloadLog)];
        [self.menu.itemArray[BRBuildMenuItemOpenBuild] setAction:@selector(openBuild)];
    }
}

#pragma mark - Actions -

- (void)rebuild {
    id selectedItem = [self.outlineView itemAtRow:[self.outlineView clickedRow]];
    if ([selectedItem isKindOfClass:[BRBuild class]]) {
        BRRebuildCommand *command = [[BRRebuildCommand alloc] initWithAPI:self.api build:(BRBuild *)selectedItem];
        [command execute:^(BOOL result, NSError *error) {
            if (result) {
                BRSyncCommand *syncCommand = [[BRSyncCommand alloc] initSyncEngine:self.syncEngine environment:self.environment];
                [syncCommand execute:nil];
            }
        }];
    }
}

- (void)abort {
    id selectedItem = [self.outlineView itemAtRow:[self.outlineView clickedRow]];
    if ([selectedItem isKindOfClass:[BRBuild class]]) {
        BRAbortCommand *command = [[BRAbortCommand alloc] initWithAPI:self.api build:(BRBuild *)selectedItem];
        [command execute:^(BOOL result, NSError *error) {
            if (result) {
                BRSyncCommand *syncCommand = [[BRSyncCommand alloc] initSyncEngine:self.syncEngine environment:self.environment];
                [syncCommand execute:nil];
            }
        }];
    }
}

- (void)downloadLog {
    id selectedItem = [self.outlineView itemAtRow:[self.outlineView clickedRow]];
    if ([selectedItem isKindOfClass:[BRBuild class]]) {
        NSString *downloadPath = [NSString stringWithFormat:@"https://app.bitrise.io/api/build/%@/logs.json?&download=log", [(BRBuild *)selectedItem slug]];
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:downloadPath]];
    }
}

- (void)openBuild {
    id selectedItem = [self.outlineView itemAtRow:[self.outlineView clickedRow]];
    if ([selectedItem isKindOfClass:[BRBuild class]]) {
        NSString *downloadPath = [NSString stringWithFormat:@"https://app.bitrise.io/build/%@", [(BRBuild *)selectedItem slug]];
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:downloadPath]];
    }
}

#pragma mark - NSMenuItemValidation -

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    id selectedItem = [self.outlineView itemAtRow:[self.outlineView clickedRow]];
    if ([selectedItem isKindOfClass:[BRBuild class]]) {
        BRBuildInfo *buildInfo = [[BRBuildInfo alloc] initWithBuild:selectedItem];
        
        BOOL buildInProgress = buildInfo.stateInfo.state == BRBuildStateInProgress;
        BOOL buildCouldBeAborted = buildInfo.stateInfo.state == BRBuildStateInProgress ||
                                   buildInfo.stateInfo.state == BRBuildStateHold;
        BOOL buildCouldBeRestarted = (!buildInProgress && [[(BRBuild *)selectedItem app] buildToken] != nil);
        
        switch (menuItem.tag) {
            case BRBuildMenuItemRebuild: return buildCouldBeRestarted;
            case BRBuildMenuItemAbort: return buildCouldBeAborted;
            case BRBuildMenuItemDownload: return !buildInProgress;
            case BRBuildMenuItemOpenBuild: return YES;
            default: return NO;
        }
    }
    
    return NO;
}

@end
