//
//  BRAccountCellView.h
//  Bitrise
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRAccountCellView : NSTableRowView

@property (weak) IBOutlet NSTextField *accountNameLabel;
@property (weak) IBOutlet NSImageView *avatarImageView;
@property (weak) IBOutlet NSTextField *emailLabel;

@end

NS_ASSUME_NONNULL_END
