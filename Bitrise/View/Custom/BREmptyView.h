//
//  BREmptyView.h
//  Bitrise
//
//  Created by Deszip on 20.06.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface BREmptyView : NSView

@property (copy, nonatomic) void (^callback)();

@end

NS_ASSUME_NONNULL_END
