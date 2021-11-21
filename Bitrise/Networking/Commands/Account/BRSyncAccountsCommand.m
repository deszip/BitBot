//
//  BRSyncAccountsCommand.m
//  BitBot
//
//  Created by Deszip on 21.11.2021.
//  Copyright © 2021 Bitrise. All rights reserved.
//

#import "BRSyncAccountsCommand.h"

@interface BRSyncAccountsCommand ()

@property (strong, nonatomic, readonly) BRSyncEngine *syncEngine;

@end

@implementation BRSyncAccountsCommand

- (instancetype)initWithSyncEngine:(BRSyncEngine *)engine {
    if (self = [super init]) {
        _syncEngine = engine;
    }
    
    return self;
}

- (void)execute:(BRCommandResult)callback {
    [self.syncEngine syncAccounts];
}

@end
