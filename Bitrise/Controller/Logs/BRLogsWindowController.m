//
//  BRLogsWindowController.m
//  Bitrise
//
//  Created by Deszip on 28/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRLogsWindowController.h"

#import "BRStyleSheet.h"

@interface BRLogsWindowController ()

@end

@implementation BRLogsWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.window.titleVisibility = NSWindowTitleHidden;
    self.window.backgroundColor = [BRStyleSheet backgroundColor];
}

@end
