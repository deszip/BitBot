//
//  BRSyncOperation.h
//  BitBot
//
//  Created by Deszip on 08/12/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "ASOperation.h"

#import "BRStorage.h"
#import "BRBitriseAPI.h"
#import "BRSyncResult.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRSyncOperation : ASOperation

- (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithStorage:(BRStorage *)storage api:(BRBitriseAPI *)api NS_DESIGNATED_INITIALIZER;

@property (copy, nonatomic, nullable) void (^syncCallback)(BRSyncResult *result);

@end

NS_ASSUME_NONNULL_END
