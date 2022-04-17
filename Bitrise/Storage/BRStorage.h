//
//  BRStorage.h
//  BitBot
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "BRAccountInfo.h"
#import "BRAppInfo.h"
@class BRBuildInfo;
@class BRBuildLog;

NS_ASSUME_NONNULL_BEGIN

typedef void(^BRStorageAction)(void);
typedef void(^BRAccountsListResult)(NSArray <BRAccountInfo *> * _Nullable accounts, NSError * _Nullable error);
typedef void(^BRStorageResult)(BOOL result, NSError * _Nullable error);

@interface BRStorage : NSObject

- (instancetype)initWithContext:(NSManagedObjectContext *)context;

- (void)perform:(BRStorageAction)action;

#pragma mark - Accounts -
- (NSArray <BTRAccount *> *)accounts:(NSError * __autoreleasing *)error;
- (BOOL)saveAccount:(BRAccountInfo *)accountInfo error:(NSError * __autoreleasing *)error;
- (BOOL)removeAccount:(NSString *)slug error:(NSError * __autoreleasing *)error;
- (BOOL)updateAccountStatus:(BOOL)status slug:(NSString *)slug error:(NSError * __autoreleasing *)error;

#pragma mark - Apps -
- (BOOL)updateApps:(NSArray <BRAppInfo *> *)appsInfo forAccount:(BTRAccount *)account error:(NSError * __autoreleasing *)error;
- (NSArray <BRApp *> *)appsForAccount:(BTRAccount *)account error:(NSError * __autoreleasing *)error;
- (BOOL)addBuildToken:(NSString *)token toApp:(NSString *)appSlug error:(NSError * __autoreleasing *)error;

#pragma mark - Builds -
- (BRBuild *)buildWithSlug:(NSString *)slug error:(NSError * __autoreleasing *)error;
- (NSArray <BRBuild *> *)runningBuilds:(NSError * __autoreleasing *)error;
- (BRBuild *)latestBuild:(BRApp *)app error:(NSError * __autoreleasing *)error;
- (BOOL)saveBuilds:(NSArray <BRBuildInfo *> *)buildsInfo forApp:(NSString *)appSlug error:(NSError * __autoreleasing *)error;

#pragma mark - Logs -
- (BOOL)saveLogMetadata:(NSDictionary *)rawLogMetadata forBuild:(BRBuild *)build error:(NSError * __autoreleasing *)error;
- (BOOL)appendLogs:(NSString *)text chunkPosition:(NSUInteger)chunkPosition toBuild:(BRBuild *)build error:(NSError * __autoreleasing *)error;
- (BOOL)markBuildLog:(BRBuildLog *)buildLog loaded:(BOOL)isLoaded error:(NSError * __autoreleasing *)error;
- (BOOL)cleanLogs:(BRBuild *)build error:(NSError * __autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END
