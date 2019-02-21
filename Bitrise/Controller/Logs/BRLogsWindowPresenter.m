//
//  BRLogsWindowPresenter.m
//  Bitrise
//
//  Created by Deszip on 21/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRLogsWindowPresenter.h"

#import "BRLogsTextViewController.h"
#import "BRSegue.h"

@interface BRLogsWindowPresenter ()

@property (weak, nonatomic) NSViewController *presentingController;

@end

@implementation BRLogsWindowPresenter

- (instancetype)initWithPresentingController:(NSViewController *)controller {
    if (self = [super init]) {
        _presentingController = controller;
    }
    
    return self;
}

- (void)presentLogs:(BRBuildInfo *)buildInfo {
    __block BRLogsTextViewController *logsController = nil;
    [[NSApp windows] enumerateObjectsUsingBlock:^(NSWindow *window, NSUInteger idx, BOOL *stop) {
        if ([window.windowController.contentViewController isKindOfClass:[BRLogsTextViewController class]]) {
            if ([[(BRLogsTextViewController *)window.windowController.contentViewController buildInfo].slug isEqualToString:buildInfo.slug]) {
                logsController = (BRLogsTextViewController *)window.windowController.contentViewController;
                *stop = YES;
            }
        }
    }];
    
    if (logsController) {
        [logsController.view.window makeKeyAndOrderFront:nil];
    } else {
        [self.presentingController performSegueWithIdentifier:kLogWindowSegue sender:buildInfo];
    }
}

@end
