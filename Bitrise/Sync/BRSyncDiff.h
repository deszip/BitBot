//
//  BRSyncDiff.h
//  Bitrise
//
//  Created by Deszip on 21/12/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BRBuildInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRSyncDiff : NSObject

@property (strong, nonatomic, readonly) NSArray <BRBuildInfo *> *started;
@property (strong, nonatomic, readonly) NSArray <BRBuildInfo *> *finished;

- (instancetype)initWithStartedBuilds:(NSArray <BRBuildInfo *> *)started finishedBuilds:(NSArray <BRBuildInfo *> *)finished;

@end

NS_ASSUME_NONNULL_END
