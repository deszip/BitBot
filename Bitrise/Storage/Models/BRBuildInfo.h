//
//  BRBuildInfo.h
//  BitBot
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BRBuildStateInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRBuildInfo : NSObject

@property (strong, nonatomic, readonly) NSDictionary *rawResponse;

@property (strong, nonatomic, readonly) BRBuildStateInfo *stateInfo;
@property (copy, nonatomic, readonly) NSString *slug;
@property (copy, nonatomic, readonly) NSString *appName;
@property (copy, nonatomic, readonly) NSString *branchName;
@property (copy, nonatomic, readonly) NSString *workflowName;

- (instancetype)initWithResponse:(NSDictionary *)response;
- (instancetype)initWithBuild:(BRBuild *)build;

@end

NS_ASSUME_NONNULL_END
