//
//  BRStorage.m
//  Bitrise
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BRStorage.h"

#import <EasyMapping/EasyMapping.h>

#import "BRAccount+Mapping.h"
#import "BRApp+Mapping.h"
#import "BRBuild+Mapping.h"

@interface BRStorage ()

@property (strong, nonatomic) NSPersistentContainer *container;

@end

@implementation BRStorage

- (instancetype)initWithContainer:(NSPersistentContainer *)container {
    if (self = [super init]) {
        _container = container;
    }
    
    return self;
}

- (void)saveAccount:(BRAccountInfo *)accountInfo {
    [self.container performBackgroundTask:^(NSManagedObjectContext *context) {
        [context setAutomaticallyMergesChangesFromParent:YES];
        BRAccount *account = [EKManagedObjectMapper objectFromExternalRepresentation:accountInfo.rawResponce withMapping:[BRAccount objectMapping] inManagedObjectContext:context];
        account.token = accountInfo.token;
        
        [self saveContext:context completion:nil];
    }];
}

- (void)removeAccount:(NSString *)token completion:(BRStorageResult)completion {
    [self.container performBackgroundTask:^(NSManagedObjectContext *context) {
        NSFetchRequest *request = [BRAccount fetchRequest];
        request.predicate = [NSPredicate predicateWithFormat:@"token = %@", token];
        
        NSError *requestError = nil;
        NSArray *accounts = [context executeFetchRequest:request error:&requestError];
        if (accounts) {
            [accounts enumerateObjectsUsingBlock:^(BRAccount *nextAccount, NSUInteger idx, BOOL *stop) {
                [context deleteObject:nextAccount];
            }];
            [self saveContext:context completion:completion];
        } else {
            NSLog(@"Failed to fetch account: %@", requestError);
            if (completion) completion(NO, requestError);
        }
    }];
}

- (void)getAccounts:(BRAccountsListResult)completion {
    [self.container performBackgroundTask:^(NSManagedObjectContext *context) {
        NSFetchRequest *request = [BRAccount fetchRequest];
        NSError *requestError = nil;
        NSArray *accounts = [context executeFetchRequest:request error:&requestError];
        if (accounts) {
            __block NSMutableArray *accountInfos = [NSMutableArray array];
            [accounts enumerateObjectsUsingBlock:^(BRAccount *nextAccount, NSUInteger idx, BOOL *stop) {
                [accountInfos addObject:[[BRAccountInfo alloc] initWithAccount:nextAccount]];
            }];
            
            completion(accountInfos, nil);
        } else {
            completion(nil, requestError);
        }
    }];
}

- (void)saveApps:(NSArray <BRAppInfo *> *)appsInfo forAccount:(BRAccountInfo *)account {
    [self.container performBackgroundTask:^(NSManagedObjectContext *context) {
        NSFetchRequest *request = [BRAccount fetchRequest];
        request.predicate = [NSPredicate predicateWithFormat:@"slug == %@", account.slug];
        NSError *requestError = nil;
        NSArray *accounts = [context executeFetchRequest:request error:&requestError];
        if (accounts.count == 1) {
            [appsInfo enumerateObjectsUsingBlock:^(BRAppInfo *appInfo, NSUInteger idx, BOOL *stop) {
                BRApp *app = [EKManagedObjectMapper objectFromExternalRepresentation:appInfo.rawResponse withMapping:[BRApp objectMapping] inManagedObjectContext:context];
                app.account = accounts[0];
                [self saveContext:context completion:nil];
            }];
        } else {
            NSLog(@"Failed to save apps: %@", requestError);
        }
    }];
}

- (void)saveBuilds:(NSArray <BRBuildInfo *> *)buildsInfo forApp:(BRAppInfo *)app completion:(BRStorageResult)completion {
    [self.container performBackgroundTask:^(NSManagedObjectContext *context) {
        NSFetchRequest *request = [BRApp fetchRequest];
        request.predicate = [NSPredicate predicateWithFormat:@"slug == %@", app.slug];
        NSError *requestError = nil;
        NSArray *apps = [context executeFetchRequest:request error:&requestError];
        if (apps.count == 1) {
            [buildsInfo enumerateObjectsUsingBlock:^(BRBuildInfo *buildInfo, NSUInteger idx, BOOL *stop) {
                BRBuild *build = [EKManagedObjectMapper objectFromExternalRepresentation:buildInfo.rawResponse withMapping:[BRBuild objectMapping] inManagedObjectContext:context];
                build.app = apps[0];
                [self saveContext:context completion:completion];
            }];
        } else {
            NSLog(@"Failed to save builds: %@", requestError);
            if (completion) completion(NO, requestError);
        }
    }];
}

#pragma mark - Save -

- (void)saveContext:(NSManagedObjectContext *)context completion:(BRStorageResult)completion {
    if ([context hasChanges]) {
        NSError *saveError = nil;
        if (![context save:&saveError]) {
            NSLog(@"Failed to save context: %@", saveError);
            if (completion) completion(NO, saveError);
        } else {
            if (completion) completion(YES, nil);
        }
    }
}

@end
