//
//  BRDisableableScrollView.h
//  Bitrise
//
//  Created by Deszip on 05.08.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRDisableableScrollView : NSScrollView

@property (assign, nonatomic) BOOL scrollingEnabled;

@end

NS_ASSUME_NONNULL_END
