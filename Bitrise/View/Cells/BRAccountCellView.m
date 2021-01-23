//
//  BRAccountCellView.m
//  BitBot
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRAccountCellView.h"

#import "BRStyleSheet.h"

@implementation BRAccountCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [self.accountNameLabel setFont:[BRStyleSheet accountListFont]];
    [self.accountNameLabel setTextColor:[BRStyleSheet secondaryTextColor]];
    [self.noticeLabel setFont:[BRStyleSheet accountListFont]];
    [self.noticeLabel setTextColor:[BRStyleSheet greenColor]];
    [self.emailLabel setFont:[BRStyleSheet accountListFont]];
    [self.emailLabel setTextColor:[BRStyleSheet secondaryTextColor]];
    
    [self.avatarImageView setWantsLayer:YES];
    [self.avatarImageView.layer setCornerRadius:[BRStyleSheet accountIconCorenerRadius]];
}

@end
