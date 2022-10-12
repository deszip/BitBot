//
//  BRFilterItemProvider.h
//  BitBot
//
//  Created by Deszip on 12.10.2022.
//  Copyright © 2022 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRFilterItemProvider : NSObject

- (NSArray <NSMenuItem *> *)statusItems;

@end

NS_ASSUME_NONNULL_END
