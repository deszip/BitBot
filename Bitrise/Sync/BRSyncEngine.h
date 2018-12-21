//
//  BRSyncEngine.h
//  Bitrise
//
//  Created by Deszip on 06/12/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BRBitriseAPI.h"
#import "BRStorage.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRSyncEngine : NSObject

- (instancetype)initWithAPI:(BRBitriseAPI *)api storage:(BRStorage *)storage;

- (void)sync;

@property (copy, nonatomic, nullable) void (^syncCallback)(NSArray <BRBuildInfo *> *finishedBuilds, NSArray <BRBuildInfo *> *startedBuilds);

@end

NS_ASSUME_NONNULL_END
