//
//  BRMockBuilder.h
//  BitriseTests
//
//  Created by Deszip on 24/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BTRAccount+CoreDataClass.h"
#import "BRApp+CoreDataClass.h"
#import "BRBuild+CoreDataClass.h"
#import "BRBuildLog+CoreDataClass.h"
#import "BRLogLine+CoreDataClass.h"
#import "BRAccountInfo.h"
#import "BRAppInfo.h"
#import "BRBuildInfo.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * const kAccountSlug = @"account_slug";
static NSString * const kAccountToken = @"account_token";
static NSString * const kAccountTokenInvalid = @"account_token_invalid";

static NSString * const kAppSlug1 = @"app_slug_1";
static NSString * const kAppSlug2 = @"app_slug_2";
static NSString * const kAppSlugInvalid = @"app_slug_invalid";
static NSString * const kAppBuildToken = @"app_build_token";

static NSString * const kBuildSlug1 = @"build_slug_1";
static NSString * const kBuildSlug2 = @"build_slug_2";
static NSString * const kBuildSlug3 = @"build_slug_3";
static NSString * const kBuildSlug4 = @"build_slug_4";


@interface BRMockBuilder : NSObject

- (instancetype)initWithContext:(NSManagedObjectContext *)context;

#pragma mark - CD Models -

- (BRAccount *)buildAccountWithToken:(NSString *)token slug:(NSString *)slug;
- (BRApp *)buildAppWithSlug:(NSString *)slug forAccount:(BRAccount *)account;
- (BRBuild *)buildWithSlug:(NSString *)slug status:(NSNumber *)status app:(BRApp * _Nullable)app;
- (BRBuildLog *)logForBuild:(BRBuild * _Nullable)build;

#pragma mark - Models -

- (BRAccountInfo *)accountInfo;
- (BRAppInfo *)appInfoWithSlug:(NSString *)slug;
- (BRBuildInfo *)buildInfoWithSlug:(NSString *)slug status:(NSNumber *)status;

#pragma mark - Fetch -

- (BRBuild *)buildWithSlug:(NSString *)slug;

@end

NS_ASSUME_NONNULL_END
