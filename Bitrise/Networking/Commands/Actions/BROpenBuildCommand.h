//
//  BROpenBuildCommand.h
//  BitBot
//
//  Created by Deszip on 05/08/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "BRCommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface BROpenBuildCommand : BRCommand

- (instancetype)initWithBuildSlug:(NSString *)buildSlug;

@end

NS_ASSUME_NONNULL_END
