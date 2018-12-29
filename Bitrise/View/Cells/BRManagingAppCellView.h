//
//  BRManagingAppCellView.h
//  Bitrise
//
//  Created by Deszip on 29/12/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRManagingAppCellView : NSTableRowView

@property (weak) IBOutlet NSImageView *appIcon;
@property (weak) IBOutlet NSTextField *appName;
@property (weak) IBOutlet NSTextField *appRepoURL;

@end

NS_ASSUME_NONNULL_END
