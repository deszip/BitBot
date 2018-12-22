//
//  BREnvironment.m
//  Bitrise
//
//  Created by Deszip on 21/12/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BREnvironment.h"

@interface BREnvironment ()

@property (strong, nonatomic) BRAutorun *autorun;

@end

@implementation BREnvironment

- (instancetype)initWithAutorun:(BRAutorun *)autorun {
    if (self = [super init]) {
        _autorun = autorun;
    }
    
    return self;
}

- (void)postNotifications:(NSArray<BRBuildInfo *> *)builds forApp:(BRAppInfo *)appInfo {
    if (!builds.count) {
        return;
    }
    
    [builds enumerateObjectsUsingBlock:^(BRBuildInfo *buildInfo, NSUInteger idx, BOOL *stop) {
        NSUserNotification *notification = [NSUserNotification new];
        notification.identifier = [NSString stringWithFormat:@"%@-%lu", buildInfo.slug, (unsigned long)buildInfo.stateInfo.state];
        notification.title = appInfo.title;
        
        switch (buildInfo.stateInfo.state) {
            case BRBuildStateHold:
                notification.subtitle = @"build on hold";
                break;
            case BRBuildStateInProgress:
                notification.subtitle = @"build started";
                break;
            case BRBuildStateFailed:
                notification.subtitle = @"build failed";
                break;
            case BRBuildStateAborted:
                notification.subtitle = @"build aborted";
                break;
            case BRBuildStateSuccess:
                notification.subtitle = @"build finished";
                break;
            
            default:
                notification.subtitle = @"build state undefined";
                break;
        }
        
        notification.contentImage = [NSImage imageNamed:buildInfo.stateInfo.statusImageName];
        notification.informativeText = [NSString stringWithFormat:@"Branch: %@, workflow: %@", buildInfo.branchName, buildInfo.workflowName];
        notification.soundName = NSUserNotificationDefaultSoundName;
        
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    }];
}

- (BOOL)autolaunchEnabled {
    return [self.autorun launchOnLoginEnabled];
}
- (void)toggleAutolaunch {
    [self.autorun toggleAutolaunch];
}

- (void)quitApp {
    [NSApp terminate:self];
}

@end
