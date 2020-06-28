//
//  BRLogStatusView.m
//  Bitrise
//
//  Created by Deszip on 28/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRLogStatusView.h"

#import "BRStyleSheet.h"
#import "BRProgressObserver.h"

@interface BRLogStatusView ()

@property (strong, nonatomic) BRProgressObserver *progressObserver;
@property (strong, nonatomic) NSProgress *progress;

@end

@implementation BRLogStatusView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [self setWantsLayer:YES];
    [self.layer setCornerRadius:5.0];
    [self.layer setBackgroundColor:[NSColor grayColor].CGColor];
    
    [self.statusField setFont:[BRStyleSheet logStatusFont]];
    [self.statusField setTextColor:[BRStyleSheet primaryTextColor]];
}

- (void)addProgress:(NSProgress *)progress {
    if (!progress) {
        return;
    }
    
    if (self.progressObserver) {
        [self.progressObserver stop];
    }

    self.progress = progress;
    self.progressObserver = [BRProgressObserver new];
    [self.progressObserver bindProgress:self.progress toIndicator:self.progressIndicator];
}


@end
