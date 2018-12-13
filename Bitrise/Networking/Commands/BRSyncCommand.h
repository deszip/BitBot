//
//  BRSyncCommand.h
//  Bitrise
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BRCommand.h"
#import "BRSyncEngine.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRSyncCommand : BRCommand

- (instancetype)initSyncEngine:(BRSyncEngine *)engine;

@end

NS_ASSUME_NONNULL_END
