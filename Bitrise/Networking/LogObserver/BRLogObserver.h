//
//  BRLogObserver.h
//  Bitrise
//
//  Created by Deszip on 30/01/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BRBitriseAPI.h"
#import "BRStorage.h"
#import "ASLogLoadingOperation.h"
#import "ASLogObservingOperation.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRLogObserver : NSObject

- (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithAPI:(BRBitriseAPI *)api storage:(BRStorage *)storage NS_DESIGNATED_INITIALIZER;

- (void)startObservingBuild:(NSString *)buildSlug;
- (void)stopObservingBuild:(NSString *)buildSlug;
- (void)loadLogsForBuild:(NSString *)buildSlug callback:(BRLogLoadingCallback)callback;

@end

NS_ASSUME_NONNULL_END
