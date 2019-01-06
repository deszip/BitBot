//
//  BRAddAccountOperation.h
//  BitBot
//
//  Created by Deszip on 29/12/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "ASOperation.h"

#import "BRStorage.h"
#import "BRBitriseAPI.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRAddAccountOperation : ASOperation

- (instancetype)initWithStorage:(BRStorage *)storage api:(BRBitriseAPI *)api accountToken:(NSString *)token;

@end

NS_ASSUME_NONNULL_END
