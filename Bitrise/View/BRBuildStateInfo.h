//
//  BRBuildStateInfo.h
//  BitBot
//
//  Created by Deszip on 05/08/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BRApp+CoreDataClass.h"
#import "BRBuild+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, BRBuildState) {
    BRBuildStateUndefined = 0,
    BRBuildStateHold,
    BRBuildStateInProgress,
    BRBuildStateSuccess,
    BRBuildStateFailed,
    BRBuildStateAborted
};

@interface BRBuildStateInfo : NSObject

@property (assign, nonatomic, readonly) BRBuildState state;
@property (strong, nonatomic, readonly) NSString *statusImageName;
@property (strong, nonatomic, readonly) NSString *statusTitle;

- (instancetype)initWithBuildStatus:(NSUInteger)buildStatus holdStatus:(BOOL)holdStatus;

@end

NS_ASSUME_NONNULL_END
