//
//  BRBitriseAPI.h
//  BitBot
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BRAccountInfo.h"
#import "BRAppInfo.h"
#import "BRBuildInfo.h"

#import "BRAccountRequest.h"
#import "BRAppsRequest.h"
#import "BRBuildsRequest.h"
#import "BRAbortRequest.h"
#import "BRRebuildRequest.h"
#import "BRLogsRequest.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kBRBitriseAPIDomain;

typedef void (^APIAccountInfoCallback)(BRAccountInfo * _Nullable, NSError * _Nullable);
typedef void (^APIAppsListCallback)(NSArray <BRAppInfo *> * _Nullable, NSError * _Nullable);
typedef void (^APIBuildsListCallback)(NSArray <BRBuildInfo *> * _Nullable, NSError * _Nullable);
typedef void (^APIBuildLogCallback)(NSDictionary * _Nullable, NSError * _Nullable);
typedef void (^APIActionCallback)(BOOL status, NSError * _Nullable error);

@interface BRBitriseAPI : NSObject

- (void)getAccount:(BRAccountRequest *)request completion:(APIAccountInfoCallback)completion;
- (void)getApps:(BRAppsRequest *)request completion:(APIAppsListCallback)completion;
- (void)getBuilds:(BRBuildsRequest *)request completion:(APIBuildsListCallback)completion;

- (void)abortBuild:(BRAbortRequest *)request completion:( APIActionCallback)completion;
- (void)rebuild:(BRRebuildRequest *)request completion:(APIActionCallback)completion;

- (void)loadLogs:(BRLogsRequest *)request completion:(APIBuildLogCallback)completion;

@end

NS_ASSUME_NONNULL_END
