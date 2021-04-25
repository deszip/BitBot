//
//  ASLogLoadingOperation.h
//  Bitrise
//
//  Created by Deszip on 08/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BROperation.h"

#import "ASLogOperation.h"
#import "BRStorage.h"
#import "BRBitriseAPI.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, BRLogLoadingState) {
    BRLogLoadingStateUndefined = 0,
    BRLogLoadingStateStarted,
    BRLogLoadingStateInProgress,
    BRLogLoadingStateFinished
};
typedef void(^BRLogLoadingCallback)(BRLogLoadingState state, NSProgress * _Nullable progress);

@interface ASLogLoadingOperation : BROperation <ASLogOperation>

@property (copy, nonatomic, readonly) NSString *buildSlug;
@property (copy, nonatomic) BRLogLoadingCallback loadingCallback;

- (instancetype)initWithStorage:(BRStorage *)storage api:(BRBitriseAPI *)api buildSlug:(NSString *)buildSlug;

@end

NS_ASSUME_NONNULL_END
