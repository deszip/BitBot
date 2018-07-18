//
//  BRSyncCommand.h
//  Bitrise
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BRCommand.h"
#import "BRBitriseAPI.h"
#import "BRStorage.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRSyncCommand : NSObject <BRCommand>

- (instancetype)initWithAPI:(BRBitriseAPI *)api storage:(BRStorage *)storage;

@end

NS_ASSUME_NONNULL_END
