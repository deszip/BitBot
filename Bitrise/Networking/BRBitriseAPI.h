//
//  BRBitriseAPI.h
//  Bitrise
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BRAccountInfo.h"
#import "BRAppInfo.h"
#import "BRBuildInfo.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kBRBitriseAPIDomain;

typedef void (^APIAccountInfoCallback)(BRAccountInfo * _Nullable, NSError * _Nullable);
typedef void (^APIAppsListCallback)(NSArray <BRAppInfo *> * _Nullable, NSError * _Nullable);
typedef void (^APIBuildsListCallback)(NSArray <BRBuildInfo *> * _Nullable, NSError * _Nullable);
typedef void (^APIActionCallback)(BOOL status, NSError * _Nullable error);

@interface BRBitriseAPI : NSObject

- (void)getAccount:(NSString *)token completion:(APIAccountInfoCallback)completion;
- (void)getApps:(NSString *)token completion:(APIAppsListCallback)completion;
- (void)getBuilds:(NSString *)appSlug token:(NSString *)token after:(NSTimeInterval)after completion:(APIBuildsListCallback)completion;

- (void)abortBuild:(NSString *)buildSlug appSlug:(NSString *)appSlug token:(NSString *)token completion:(APIActionCallback)completion;
- (void)rebuild:(NSString *)buildSlug appSlug:(NSString *)appSlug token:(NSString *)token completion:(APIActionCallback)completion;

@end

NS_ASSUME_NONNULL_END
