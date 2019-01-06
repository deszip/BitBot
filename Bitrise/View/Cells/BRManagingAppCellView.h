//
//  BRManagingAppCellView.h
//  BitBot
//
//  Created by Deszip on 29/12/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRManagingAppCellView : NSTableRowView

@property (weak) IBOutlet NSImageView *appIcon;
@property (weak) IBOutlet NSTextField *appName;
@property (weak) IBOutlet NSTextField *appRepoURL;
@property (weak) IBOutlet NSTextField *buildToken;

@end

NS_ASSUME_NONNULL_END
