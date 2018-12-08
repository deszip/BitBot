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

#pragma mark - Synchronous API -
- (void)perform:(void (^)(void))action;
- (NSArray <BRAccount *> *)accounts:(NSError * __autoreleasing *)error;
- (BOOL)updateApps:(NSArray <BRAppInfo *> *)appsInfo forAccount:(BRAccount *)account error:(NSError * __autoreleasing *)error;
- (NSArray <BRApp *> *)appsForAccount:(BRAccount *)account error:(NSError * __autoreleasing *)error;

- (void)saveAccount:(BRAccountInfo *)accountInfo;
- (void)removeAccount:(NSString *)token completion:(BRStorageResult)completion;
- (void)getAccounts:(BRAccountsListResult)completion;

- (void)saveApps:(NSArray <BRAppInfo *> *)appsInfo forAccount:(BRAccountInfo *)account;
- (void)saveBuilds:(NSArray <BRBuildInfo *> *)buildsInfo forApp:(BRAppInfo *)app completion:(BRStorageResult _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
