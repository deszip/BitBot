//
//  BRAddAccountOperation.h
//  BitBot
//
//  Created by Deszip on 29/12/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BROperation.h"

#import "BRStorage.h"
#import "BRBitriseAPI.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRAddAccountOperation : BROperation

@property (copy, nonatomic, nullable) void (^resultCallback)(NSError * __nullable error);

- (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithStorage:(BRStorage *)storage api:(BRBitriseAPI *)api accountToken:(NSString *)token;

@end

NS_ASSUME_NONNULL_END
