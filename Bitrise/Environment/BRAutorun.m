//
//  CHAutorun.m
//  Chisti
//
//  Created by Deszip on 03/06/2018.
//  Copyright © 2018 Deszip. All rights reserved.
//

#import "BRAutorun.h"

#import <ServiceManagement/ServiceManagement.h>

static NSString * const kHelperBundleID = @"CH.ChistiHelper";

@implementation BRAutorun

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

- (BOOL)launchOnLoginEnabled {
    LSSharedFileListRef loginItemsListRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    CFArrayRef snapshotRef = LSSharedFileListCopySnapshot(loginItemsListRef, NULL);
    NSArray* loginItems = CFBridgingRelease(snapshotRef);
    NSURL *bundleURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    for (id item in loginItems) {
        LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)CFBridgingRetain(item);
        CFURLRef itemURLRef;
        if (LSSharedFileListItemResolve(itemRef, 0, &itemURLRef, NULL) == noErr) {
            NSURL *itemURL = (NSURL *)CFBridgingRelease(itemURLRef);
            if ([itemURL isEqual:bundleURL]) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (void)setLaunchOnLogin:(BOOL)launchOnLogin {
    NSURL *bundleURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    LSSharedFileListRef loginItemsListRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
    if (launchOnLogin) {
        NSDictionary *properties;
        properties = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"com.apple.loginitem.HideOnLaunch"];
        LSSharedFileListItemRef itemRef = LSSharedFileListInsertItemURL(loginItemsListRef, kLSSharedFileListItemLast, NULL, NULL, (CFURLRef)CFBridgingRetain(bundleURL), (CFDictionaryRef)CFBridgingRetain(properties),NULL);
        if (itemRef) {
            CFRelease(itemRef);
        }
    } else {
        LSSharedFileListRef loginItemsListRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
        CFArrayRef snapshotRef = LSSharedFileListCopySnapshot(loginItemsListRef, NULL);
        NSArray* loginItems = CFBridgingRelease(snapshotRef);
        
        for (id item in loginItems) {
            LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)CFBridgingRetain(item);
            CFURLRef itemURLRef;
            if (LSSharedFileListItemResolve(itemRef, 0, &itemURLRef, NULL) == noErr) {
                NSURL *itemURL = (NSURL *)CFBridgingRelease(itemURLRef);
                if ([itemURL isEqual:bundleURL]) {
                    LSSharedFileListItemRemove(loginItemsListRef, itemRef);
                }
            }
        }
    }
}

#pragma clang diagnostic pop

- (void)toggleAutolaunch {
    [self setLaunchOnLogin:![self launchOnLoginEnabled]];
}

@end
