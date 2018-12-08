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

typedef void (^APIAccountInfoCallback)(BRAccountInfo * _Nullable, NSError * _Nullable);
typedef void (^APIAppsListCallback)(NSArray <BRAppInfo *> * _Nullable, NSError * _Nullable);
typedef void (^APIBuildsListCallback)(NSArray <BRBuildInfo *> * _Nullable, NSError * _Nullable);

@interface BRBitriseAPI : NSObject

- (void)getAccount:(NSString *)token completion:(APIAccountInfoCallback)completion;
- (void)getApps:(NSString *)token completion:(APIAppsListCallback)completion;

- (void)getBuilds:(BRAppInfo *)app account:(BRAccountInfo *)account completion:(APIBuildsListCallback)completion;
- (void)updateBuilds:(BRAppInfo *)app account:(BRAccountInfo *)account after:(NSTimeInterval)after completion:(APIBuildsListCallback)completion;

@end

NS_ASSUME_NONNULL_END
