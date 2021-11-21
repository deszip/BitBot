//
//  BRSyncAccountsCommand.h
//  BitBot
//
//  Created by Deszip on 21.11.2021.
//  Copyright © 2021 Bitrise. All rights reserved.
//

#import "BRCommand.h"
#import "BRSyncEngine.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRSyncAccountsCommand : BRCommand

- (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithSyncEngine:(BRSyncEngine *)engine NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
