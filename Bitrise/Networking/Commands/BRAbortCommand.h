//
//  BRAbortCommand.h
//  Bitrise
//
//  Created by Deszip on 05/08/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "BRCommand.h"
#import "BRBitriseAPI.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRAbortCommand : BRCommand

- (instancetype)initWithAPI:(BRBitriseAPI *)api appSlug:(NSString *)appSlug buildSlug:(NSString *)buildSlug token:(NSString *)token;

@end

NS_ASSUME_NONNULL_END
