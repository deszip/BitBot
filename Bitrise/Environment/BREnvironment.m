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
    [builds enumerateObjectsUsingBlock:^(BRBuildInfo *buildInfo, NSUInteger idx, BOOL *stop) {
        NSUserNotification *notification = [NSUserNotification new];
        notification.identifier = buildInfo.slug;
        notification.title = @"appspector-ios-sdk";
        notification.subtitle = @"build started";
        notification.informativeText = @"Branch: develop, workflow: develop";
        notification.soundName = NSUserNotificationDefaultSoundName;
        notification.contentImage = [NSImage imageNamed:@"foo"];
        
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    }];
}

@end
