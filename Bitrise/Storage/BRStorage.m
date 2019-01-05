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
#import "BRMacro.h"

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
        [_context setAutomaticallyMergesChangesFromParent:YES];
    }
    
    return self;
}

#pragma mark - Synchronous API -

- (void)perform:(void (^)(void))action {
    [self.context performBlock:^{
        action();
    }];
}

#pragma mark - Accounts  -

- (NSArray <BRAccount *> *)accounts:(NSError * __autoreleasing *)error {
    NSFetchRequest *request = [BRAccount fetchRequest];
    NSArray *accounts = [self.context executeFetchRequest:request error:error];
    
    return accounts;
}

- (BRAccount *)accountWithToken:(NSString *)token error:(NSError * __autoreleasing *)error {
    NSFetchRequest *request = [BRAccount fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"token = %@", token];
    NSArray *accounts = [self.context executeFetchRequest:request error:error];
    
    if (accounts.count == 1) {
        return accounts.firstObject;
    }
    
    return nil;
}

- (void)saveAccount:(BRAccountInfo *)accountInfo {
    [self.context performBlock:^{
        [self.context setAutomaticallyMergesChangesFromParent:YES];
        BRAccount *account = [EKManagedObjectMapper objectFromExternalRepresentation:accountInfo.rawResponce withMapping:[BRAccount objectMapping] inManagedObjectContext:self.context];
        account.token = accountInfo.token;
        
        NSError *error;
        [self saveContext:self.context error:&error];
    }];
}

- (void)removeAccount:(NSString *)slug completion:(BRStorageResult)completion {
    [self.context performBlock:^{
        NSFetchRequest *request = [BRAccount fetchRequest];
        request.predicate = [NSPredicate predicateWithFormat:@"slug = %@", slug];
        
        NSError *requestError = nil;
        NSArray *accounts = [self.context executeFetchRequest:request error:&requestError];
        if (accounts) {
            [accounts enumerateObjectsUsingBlock:^(BRAccount *nextAccount, NSUInteger idx, BOOL *stop) {
                [self.context deleteObject:nextAccount];
            }];
            if (![self saveContext:self.context error:&requestError]) {
                BR_SAFE_CALL(completion, NO, requestError);
            }
        } else {
            NSLog(@"Failed to fetch account: %@", requestError);
            BR_SAFE_CALL(completion, NO, requestError);
        }
    }];
}

#pragma mark - Apps -

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
            [self saveContext:self.context error:error];
        }];
        
        return YES;
    } else {
        NSLog(@"Failed to save apps: %@", requestError);
        return NO;
    }
}

- (NSArray <BRApp *> *)appsForAccount:(BRAccount *)account error:(NSError * __autoreleasing *)error {
    NSFetchRequest *request = [BRApp fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"account.slug == %@", account.slug];
    NSArray <BRApp *> *apps = [self.context executeFetchRequest:request error:error];
    
    return apps;
}

- (BOOL)addBuildToken:(NSString *)token toApp:(NSString *)appSlug error:(NSError * __autoreleasing *)error {
    NSFetchRequest *request = [BRApp fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"slug == %@", appSlug];
    NSArray <BRApp *> *apps = [self.context executeFetchRequest:request error:error];
    
    if (apps.count == 1 && token) {
        [apps.firstObject setBuildToken:token];
        return [self saveContext:self.context error:error];
    }
    
    return NO;
}

#pragma mark - Builds -

- (NSArray <BRBuild *> *)runningBuilds:(NSError * __autoreleasing *)error {
    NSFetchRequest *request = [BRBuild fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"status = 0"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"triggerTime" ascending:NO]];
    
    NSArray <BRBuild *> *builds = [self.context executeFetchRequest:request error:error];
    
    return builds;
}

- (BRBuild *)latestBuild:(BRApp *)app error:(NSError * __autoreleasing *)error {
    NSFetchRequest *request = [BRBuild fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"app.slug == %@ && status != 0", app.slug];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"triggerTime" ascending:YES]];
    request.fetchLimit = 1;
    
    NSArray <BRBuild *> *builds = [self.context executeFetchRequest:request error:error];
    
    if (builds.count == 1) {
        return [builds firstObject];
    }
    
    return nil;
}

- (BOOL)saveBuilds:(NSArray <BRBuildInfo *> *)buildsInfo forApp:(NSString *)appSlug error:(NSError * __autoreleasing *)error {
    NSFetchRequest *request = [BRApp fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"slug == %@", appSlug];
    NSArray *apps = [self.context executeFetchRequest:request error:error];
    __block BOOL result = YES;
    if (apps.count == 1) {
        [buildsInfo enumerateObjectsUsingBlock:^(BRBuildInfo *buildInfo, NSUInteger idx, BOOL *stop) {
            BRBuild *build = [EKManagedObjectMapper objectFromExternalRepresentation:buildInfo.rawResponse withMapping:[BRBuild objectMapping] inManagedObjectContext:self.context];
            build.app = apps[0];
            if (![self saveContext:self.context error:error]) {
                result = NO;
            }
        }];
    } else {
        NSLog(@"Failed to save builds: %@", *error);
        result = NO;
    }
    
    return result;
}

#pragma mark - Save -

- (BOOL)saveContext:(NSManagedObjectContext *)context error:(NSError * __autoreleasing *)error {
    if ([context hasChanges]) {
        return [context save:error];
    }
    
    return YES;
}

@end
