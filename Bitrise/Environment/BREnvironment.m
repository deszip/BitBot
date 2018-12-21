//
//  BREnvironment.m
//  Bitrise
//
//  Created by Deszip on 21/12/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BREnvironment.h"

@implementation BREnvironment

- (void)postNotifications:(NSArray<BRBuildInfo *> *)builds {
    if (!builds.count) {
        return;
    }
    
    [builds enumerateObjectsUsingBlock:^(BRBuildInfo *buildInfo, NSUInteger idx, BOOL *stop) {
        NSUserNotification *notification = [NSUserNotification new];
        notification.identifier = [NSString stringWithFormat:@"%@-%lu", buildInfo.slug, (unsigned long)buildInfo.stateInfo.state];
        notification.title = buildInfo.appName;
        
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

@end
