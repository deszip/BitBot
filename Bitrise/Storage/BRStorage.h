//
//  BRStorage.h
//  Bitrise
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "BRAccountInfo.h"
#import "BRAppInfo.h"
#import "BRBuildInfo.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^BRAccountsListResult)(NSArray <BRAccountInfo *> * _Nullable accounts, NSError * _Nullable error);
typedef void(^BRStorageResult)(BOOL result, NSError * _Nullable error);

@interface BRStorage : NSObject

- (instancetype)initWithContainer:(NSPersistentContainer *)container;

- (void)perform:(void (^)(void))action;

#pragma mark - Accounts -
- (NSArray <BRAccount *> *)accounts:(NSError * __autoreleasing *)error;
- (BRAccount *)accountWithToken:(NSString *)token error:(NSError * __autoreleasing *)error;
- (void)saveAccount:(BRAccountInfo *)accountInfo;
- (void)removeAccount:(NSString *)token completion:(BRStorageResult)completion;

#pragma mark - Apps -
- (BOOL)updateApps:(NSArray <BRAppInfo *> *)appsInfo forAccount:(BRAccount *)account error:(NSError * __autoreleasing *)error;
- (NSArray <BRApp *> *)appsForAccount:(BRAccount *)account error:(NSError * __autoreleasing *)error;
- (BOOL)addBuildToken:(NSString *)token toApp:(NSString *)appSlug error:(NSError * __autoreleasing *)error;

#pragma mark - Builds -
- (NSArray <BRBuild *> *)runningBuilds:(NSError * __autoreleasing *)error;
- (BRBuild *)latestBuild:(BRApp *)app error:(NSError * __autoreleasing *)error;
- (BOOL)saveBuilds:(NSArray <BRBuildInfo *> *)buildsInfo forApp:(NSString *)appSlug error:(NSError * __autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END
