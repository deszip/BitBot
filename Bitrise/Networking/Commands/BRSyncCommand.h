//
//  BRSyncCommand.h
//  Bitrise
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BRBitriseAPI.h"
#import "BRStorage.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRSyncCommand : NSObject

- (instancetype)initWithAPI:(BRBitriseAPI *)api storage:(BRStorage *)storage;
- (void)execute;

@end

NS_ASSUME_NONNULL_END
