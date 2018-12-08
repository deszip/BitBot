//
//  BRSyncOperation.h
//  Bitrise
//
//  Created by Deszip on 08/12/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "ASOperation.h"

#import "BRStorage.h"
#import "BRBitriseAPI.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRSyncOperation : ASOperation

- (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithStorage:(BRStorage *)storage api:(BRBitriseAPI *)api NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
