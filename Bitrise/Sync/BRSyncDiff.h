//
//  BRSyncDiff.h
//  BitBot
//
//  Created by Deszip on 21/12/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BRBuildInfo;

NS_ASSUME_NONNULL_BEGIN

@interface BRSyncDiff : NSObject

@property (strong, nonatomic, readonly) NSArray <BRBuildInfo *> *started;
@property (strong, nonatomic, readonly) NSArray <BRBuildInfo *> *running;
@property (strong, nonatomic, readonly) NSArray <BRBuildInfo *> *finished;

- (instancetype)initWithStartedBuilds:(NSArray <BRBuildInfo *> *)started
                       runningBuilds:(NSArray <BRBuildInfo *> *)running
                       finishedBuilds:(NSArray <BRBuildInfo *> *)finished;

@end

NS_ASSUME_NONNULL_END
