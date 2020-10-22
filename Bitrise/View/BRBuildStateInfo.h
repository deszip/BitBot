//
//  BRBuildStateInfo.h
//  BitBot
//
//  Created by Deszip on 05/08/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BitriseCompat.h"
#import "BRApp+CoreDataClass.h"
#import "BRBuild+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, BRBuildState) {
    BRBuildStateUndefined = 0,
    BRBuildStateWaitingForWorker,
    BRBuildStateHold,
    BRBuildStateInProgress,
    BRBuildStateSuccess,
    BRBuildStateFailed,
    BRBuildStateAborted
};

@interface BRBuildStateInfo : NSObject <NSSecureCoding>

@property (assign, nonatomic, readonly) BRBuildState state;
@property (strong, nonatomic, readonly) NSString *statusImageName;
@property (strong, nonatomic, readonly) NSString *notificationImageName;
@property (strong, nonatomic, readonly) NSString *statusTitle;
@property (strong, nonatomic, readonly) NSColor *statusColor;

- (instancetype)initWithBuildStatus:(NSUInteger)buildStatus
                         holdStatus:(BOOL)holdStatus
                            waiting:(BOOL)isWaiting;

@end

NS_ASSUME_NONNULL_END
