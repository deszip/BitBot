//
//  BRAPIObserver.h
//  Bitrise
//
//  Created by Deszip on 13/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BRBitriseAPI.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRAPIObserver : NSObject

- (instancetype)initWithAPI:(BRBitriseAPI *)api;

- (void)startObservingBuilds;
- (void)stopObservingBuilds;

@end

NS_ASSUME_NONNULL_END
