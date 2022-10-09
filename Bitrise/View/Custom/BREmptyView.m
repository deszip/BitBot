//
//  BREmptyView.m
//  Bitrise
//
//  Created by Deszip on 20.06.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

#import "BREmptyView.h"

#import "BRStyleSheet.h"
#import "BRAboutTextView.h"

@interface BREmptyView ()

@property (weak) IBOutlet NSImageView *emptyIcon;
@property (weak) IBOutlet NSTextField *titleField;
@property (weak) IBOutlet NSTextField *subtitleField;
@property (weak) IBOutlet BRAboutTextView *subtitleTextView;
@property (weak) IBOutlet NSButton *addAccountButton;

@end

@implementation BREmptyView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [self.titleField setTextColor:[BRStyleSheet textColor]];
    [self.subtitleField setTextColor:[BRStyleSheet textColor]];
 
    [self.titleField setFont:[BRStyleSheet emptyTitleFont]];
    [self.subtitleField setFont:[BRStyleSheet emptySubtitleFont]];
    
    [self.subtitleTextView setAutomaticLinkDetectionEnabled:YES];
    [self.subtitleTextView setTextColor:[BRStyleSheet textColor]];
    [self.subtitleTextView setFont:[BRStyleSheet emptySubtitleFont]];
}

- (void)setViewType:(BREmptyViewType)viewType {
    _viewType = viewType;
    switch (viewType) {
        case BREmptyViewTypeNoData:
            self.titleField.stringValue = @"NO BUILDS MATCHING FILTER";
            self.subtitleTextView.hidden = YES;
            self.addAccountButton.hidden = YES;
            break;
            
        case BREmptyViewTypeNoAccounts:
            self.titleField.stringValue = @"NO ACCOUNTS YET";
            self.subtitleTextView.hidden = NO;
            self.addAccountButton.hidden = NO;
            break;
    }
}

- (IBAction)addAccount:(id)sender {
    self.callback();
}

@end
