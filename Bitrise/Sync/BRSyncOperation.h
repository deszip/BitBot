//
//  BRSyncOperation.h
//  BitBot
//
//  Created by Deszip on 08/12/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BROperation.h"

#import "BRStorage.h"
#import "BRBitriseAPI.h"
#import "BRSyncResult.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRSyncOperation : BROperation

@property (copy, nonatomic, nullable) void (^syncCallback)(BRSyncResult *result);

- (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithStorage:(BRStorage *)storage api:(BRBitriseAPI *)api NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
