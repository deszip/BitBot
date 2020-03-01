//
//  BRGetAccountCommand.h
//  BitBot
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BRCommand.h"
#import "BRSyncEngine.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRGetAccountCommand : BRCommand

- (instancetype)initWithSyncEngine:(BRSyncEngine *)engine token:(NSString *)token;

@end

NS_ASSUME_NONNULL_END
