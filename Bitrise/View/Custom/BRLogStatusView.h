//
//  BRLogStatusView.h
//  Bitrise
//
//  Created by Deszip on 28/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRLogStatusView : NSView

@property (weak, nonatomic) IBOutlet NSTextField *statusField;
@property (weak, nonatomic) IBOutlet NSProgressIndicator *progressIndicator;

- (void)addProgress:(NSProgress *)progress;

@end

NS_ASSUME_NONNULL_END
