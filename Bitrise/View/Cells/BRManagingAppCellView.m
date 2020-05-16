//
//  BRManagingAppCellView.m
//  BitBot
//
//  Created by Deszip on 29/12/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRManagingAppCellView.h"

#import "BRStyleSheet.h"

@implementation BRManagingAppCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [self.appName setFont:[BRStyleSheet accountListFont]];
    [self.appRepoURL setFont:[BRStyleSheet accountListFont]];
    
    [self.appIcon setWantsLayer:YES];
    [self.appIcon.layer setCornerRadius:[BRStyleSheet accountIconCorenerRadius]];
}

@end
