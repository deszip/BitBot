//
//  BREmptyView.m
//  Bitrise
//
//  Created by Deszip on 20.06.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

#import "BREmptyView.h"

#import "BRStyleSheet.h"

@interface BREmptyView ()

@property (weak) IBOutlet NSImageView *emptyIcon;
@property (weak) IBOutlet NSTextField *titleField;
@property (weak) IBOutlet NSTextField *subtitleField;
@property (weak) IBOutlet NSButton *addAccountButton;

@end

@implementation BREmptyView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [self.titleField setTextColor:[BRStyleSheet textColor]];
    [self.subtitleField setTextColor:[BRStyleSheet textColor]];
 
    [self.titleField setFont:[BRStyleSheet emptyTitleFont]];
    [self.subtitleField setFont:[BRStyleSheet emptySubtitleFont]];
}

- (IBAction)addAccount:(id)sender {
    self.callback();
}

@end
