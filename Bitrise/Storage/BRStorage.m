//
//  BRStorage.m
//  Bitrise
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BRStorage.h"

#import <EasyMapping/EasyMapping.h>

#import "NSArray+FRP.h"

#import "BRAccount+Mapping.h"
#import "BRApp+Mapping.h"
#import "BRBuild+Mapping.h"

@interface BRStorage ()

@property (strong, nonatomic) NSPersistentContainer *container;
@property (strong, nonatomic) NSManagedObjectContext *context;

@end

@implementation BRStorage

- (instancetype)initWithContainer:(NSPersistentContainer *)container {
    if (self = [super init]) {
        _container = container;
        _context = [container newBackgroundContext];
    }
    
    return self;
}

#pragma mark - Synchronous API -

- (void)perform:(void (^)(void))action {
    [self.context performBlock:^{
        action();
    }];
}

- (void)saveAccount:(BRAccountInfo *)accountInfo {
    [self.context performBlock:^{
        [self.context setAutomaticallyMergesChangesFromParent:YES];
        BRAccount *account = [EKManagedObjectMapper objectFromExternalRepresentation:accountInfo.rawResponce withMapping:[BRAccount objectMapping] inManagedObjectContext:self.context];
        account.token = accountInfo.token;
        
        [self saveContext:self.context completion:nil];
    }];
}

- (void)removeAccount:(NSString *)token completion:(BRStorageResult)completion {
    [self.context performBlock:^{
        NSFetchRequest *request = [BRAccount fetchRequest];
        request.predicate = [NSPredicate predicateWithFormat:@"token = %@", token];
        
        NSError *requestError = nil;
        NSArray *accounts = [self.context executeFetchRequest:request error:&requestError];
        if (accounts) {
            [accounts enumerateObjectsUsingBlock:^(BRAccount *nextAccount, NSUInteger idx, BOOL *stop) {
                [self.context deleteObject:nextAccount];
            }];
            [self saveContext:self.context completion:completion];
        } else {
            NSLog(@"Failed to fetch account: %@", requestError);
            if (completion) completion(NO, requestError);
        }
    }];
}

//- (void)getAccounts:(BRAccountsListResult)completion {
//    [self perform:^{
//        NSError *fetchError;
//        NSArray *accounts = [self accounts:&fetchError];
//        if (accounts) {
//            completion(accounts, nil);
//        } else {
//            completion(nil, fetchError);
//        }
//    }];
//}

- (NSArray <BRAccount *> *)accounts:(NSError * __autoreleasing *)error {
    NSFetchRequest *request = [BRAccount fetchRequest];
    NSArray *accounts = [self.context executeFetchRequest:request error:error];
    
    return accounts;
}

- (NSArray <BRApp *> *)appsForAccount:(BRAccount *)account error:(NSError * __autoreleasing *)error {
    NSFetchRequest *request = [BRApp fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"account.slug == %@", account.slug];
    NSArray <BRApp *> *apps = [self.context executeFetchRequest:request error:error];
    
    return apps;
}

//- (void)saveApps:(NSArray <BRAppInfo *> *)appsInfo forAccount:(BRAccountInfo *)account {
//    [self perform:^{
//        NSError *error;
//        [self updateApps:appsInfo forAccount:account error:&error];
//    }];
//}

- (BOOL)updateApps:(NSArray <BRAppInfo *> *)appsInfo forAccount:(BRAccount *)account error:(NSError * __autoreleasing *)error {
    NSFetchRequest *request = [BRAccount fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"slug == %@", account.slug];
    NSError *requestError = nil;
    NSArray *accounts = [self.context executeFetchRequest:request error:&requestError];
    if (accounts.count == 1) {
        // Fetch outdated account apps
        NSFetchRequest *request = [BRApp fetchRequest];
        NSArray *appSlugs = [appsInfo valueForKeyPath:@"slug"];
        request.predicate = [NSPredicate predicateWithFormat:@"account.slug == %@ AND NOT (slug IN %@)", account.slug, appSlugs];
        NSError *requestError = nil;
        NSArray *outdatedApps = [self.context executeFetchRequest:request error:&requestError];
        [outdatedApps enumerateObjectsUsingBlock:^(BRApp *app, NSUInteger idx, BOOL *stop) {
            [self.context deleteObject:app];
        }];
        
        [appsInfo enumerateObjectsUsingBlock:^(BRAppInfo *appInfo, NSUInteger idx, BOOL *stop) {
            BRApp *app = [EKManagedObjectMapper objectFromExternalRepresentation:appInfo.rawResponse withMapping:[BRApp objectMapping] inManagedObjectContext:self.context];
            app.account = accounts[0];
            [self saveContext:self.context completion:nil];
        }];
        
        return YES;
    } else {
        NSLog(@"Failed to save apps: %@", requestError);
        return NO;
    }
}


- (void)saveBuilds:(NSArray <BRBuildInfo *> *)buildsInfo forApp:(BRAppInfo *)app completion:(BRStorageResult)completion {
    [self.context performBlock:^{
        NSFetchRequest *request = [BRApp fetchRequest];
        request.predicate = [NSPredicate predicateWithFormat:@"slug == %@", app.slug];
        NSError *requestError = nil;
        NSArray *apps = [self.context executeFetchRequest:request error:&requestError];
        if (apps.count == 1) {
            [buildsInfo enumerateObjectsUsingBlock:^(BRBuildInfo *buildInfo, NSUInteger idx, BOOL *stop) {
                BRBuild *build = [EKManagedObjectMapper objectFromExternalRepresentation:buildInfo.rawResponse withMapping:[BRBuild objectMapping] inManagedObjectContext:self.context];
                build.app = apps[0];
                [self saveContext:self.context completion:completion];
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
