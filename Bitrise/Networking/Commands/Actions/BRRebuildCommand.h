//
//  BRRebuildCommand.h
//  BitBot
//
//  Created by Deszip on 05/08/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRCommand.h"
#import "BRBitriseAPI.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRRebuildCommand : BRCommand

- (instancetype)initWithAPI:(BRBitriseAPI *)api build:(BRBuild *)build;

@end

NS_ASSUME_NONNULL_END
