//
//  BRStorage.m
//  BitBot
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRStorage.h"

#import <EasyMapping/EasyMapping.h>

#import "BRLogger.h"
#import "NSArray+FRP.h"
#import "BRMacro.h"

#import "BTRAccount+Mapping.h"
#import "BRApp+Mapping.h"
#import "BRBuild+Mapping.h"
#import "BRBuildLog+Mapping.h"
#import "BRLogLine+CoreDataClass.h"
#import "BRLogStep+CoreDataClass.h"

#import "BRLogStorage.h"
#import "BRBuildInfo.h"


@interface BRStorage ()

@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) BRLogStorage *logStorage;

@end

@implementation BRStorage

- (instancetype)initWithContext:(NSManagedObjectContext *)context {
    if (self = [super init]) {
        _context = context;
        [_context setAutomaticallyMergesChangesFromParent:YES];
        
        _logStorage = [[BRLogStorage alloc] initWithContext:context];
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

- (NSArray <BTRAccount *> *)accounts:(NSError * __autoreleasing *)error {
    NSFetchRequest *request = [BTRAccount fetchRequest];
    NSArray *accounts = [self.context executeFetchRequest:request error:error];
    
    return accounts;
}

- (BOOL)saveAccount:(BRAccountInfo *)accountInfo error:(NSError * __autoreleasing *)error {
    BTRAccount *account = [EKManagedObjectMapper objectFromExternalRepresentation:accountInfo.rawResponce withMapping:[BTRAccount objectMapping] inManagedObjectContext:self.context];
    account.token = accountInfo.token;
    
    return [self saveContext:self.context error:error];
}

- (BOOL)removeAccount:(NSString *)slug error:(NSError * __autoreleasing *)error {
    NSFetchRequest *request = [BTRAccount fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"slug = %@", slug];

    NSError *requestError = nil;
    NSArray *accounts = [self.context executeFetchRequest:request error:&requestError];
    if (accounts.count > 0) {
        [accounts enumerateObjectsUsingBlock:^(BTRAccount *nextAccount, NSUInteger idx, BOOL *stop) {
            [self.context deleteObject:nextAccount];
        }];
        return [self saveContext:self.context error:error];
    } else {
        return NO;
    }
}

- (BOOL)updateAccountStatus:(BOOL)status slug:(NSString *)slug error:(NSError * __autoreleasing *)error {
    BTRAccount *account = [self fetchAccount:slug error:error];
    if (account) {
        account.enabled = status;
        return [self saveContext:self.context error:error];
    } else {
        return NO;
    }
}

#pragma mark - Apps -

- (BOOL)updateApps:(NSArray <BRAppInfo *> *)appsInfo forAccount:(BTRAccount *)account error:(NSError * __autoreleasing *)error {
    NSFetchRequest *request = [BTRAccount fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"slug == %@", account.slug];
    NSError *requestError = nil;
    NSArray *accounts = [self.context executeFetchRequest:request error:&requestError];
    if (accounts.count == 1) {
        // Fetch and remove outdated account apps
        NSFetchRequest *request = [BRApp fetchRequest];
        NSArray *appSlugs = [appsInfo valueForKeyPath:@"slug"];
        request.predicate = [NSPredicate predicateWithFormat:@"account.slug == %@ AND NOT (slug IN %@)", account.slug, appSlugs];
        NSError *requestError = nil;
        NSArray *outdatedApps = [self.context executeFetchRequest:request error:&requestError];
        [outdatedApps enumerateObjectsUsingBlock:^(BRApp *app, NSUInteger idx, BOOL *stop) {
            [self.context deleteObject:app];
        }];
        
        // Insert new apps
        [appsInfo enumerateObjectsUsingBlock:^(BRAppInfo *appInfo, NSUInteger idx, BOOL *stop) {
            BRApp *app = [EKManagedObjectMapper objectFromExternalRepresentation:appInfo.rawResponse withMapping:[BRApp objectMapping] inManagedObjectContext:self.context];
            app.account = accounts[0];
            [self saveContext:self.context error:error];
        }];
        
        return YES;
    } else {
        return NO;
    }
}

- (NSArray <BRApp *> *)appsForAccount:(BTRAccount *)account error:(NSError * __autoreleasing *)error {
    NSFetchRequest *request = [BRApp fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"account.slug == %@", account.slug];
    NSArray <BRApp *> *apps = [self.context executeFetchRequest:request error:error];
    
    return apps;
}

- (BOOL)addBuildToken:(NSString *)token toApp:(NSString *)appSlug error:(NSError * __autoreleasing *)error {
    NSFetchRequest *request = [BRApp fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"slug == %@", appSlug];
    NSArray <BRApp *> *apps = [self.context executeFetchRequest:request error:error];
    
    if (apps.count == 1) {
        [apps.firstObject setBuildToken:token];
        return [self saveContext:self.context error:error];
    }
    
    return NO;
}

#pragma mark - Builds -

- (BRBuild *)buildWithSlug:(NSString *)slug error:(NSError * __autoreleasing *)error {
    NSFetchRequest *request = [BRBuild fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"slug = %@", slug];
    
    NSArray <BRBuild *> *builds = [self.context executeFetchRequest:request error:error];
    if (builds.count == 1) {
        return builds.firstObject;
    }
    
    return nil;
}

- (NSArray <BRBuild *> *)runningBuilds:(NSError * __autoreleasing *)error {
    NSFetchRequest *request = [BRBuild fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"status = 0"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"triggerTime" ascending:NO]];
    
    NSArray <BRBuild *> *builds = [self.context executeFetchRequest:request error:error];
    
    return builds;
}

- (BRBuild *)latestBuild:(BRApp *)app error:(NSError * __autoreleasing *)error {
    NSFetchRequest *request = [BRBuild fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"app.slug == %@ && status == 0", app.slug];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"triggerTime" ascending:YES]];
    request.fetchLimit = 1;
    
    NSArray <BRBuild *> *runningBuilds = [self.context executeFetchRequest:request error:error];
    
    // If we have running builds return oldest, otherwise - most recent build
    if (runningBuilds.count > 0) {
        return [runningBuilds firstObject];
    } else {
        NSFetchRequest *request = [BRBuild fetchRequest];
        request.predicate = [NSPredicate predicateWithFormat:@"app.slug == %@ && status != 0", app.slug];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"triggerTime" ascending:NO]];
        request.fetchLimit = 1;
        
        NSArray <BRBuild *> *finishedBuilds = [self.context executeFetchRequest:request error:error];
        if (finishedBuilds.count > 0) {
            return finishedBuilds.firstObject;
        }
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
            build.createdAt = [NSDate date];
        }];
        result = [self saveContext:self.context error:error];
    } else {
        BRLog(LL_WARN, LL_STORAGE, @"Failed to save builds: %@", *error);
        result = NO;
    }
    
    return result;
}

#pragma mark - Accessors -

- (BTRAccount *)fetchAccount:(NSString *)slug error:(NSError * __autoreleasing *)error {
    NSFetchRequest *request = [BTRAccount fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"slug = %@", slug];
    
    NSArray *accounts = [self.context executeFetchRequest:request error:error];
    if (accounts.count > 0) {
        return accounts.firstObject;
    } else {
        return nil;
    }
}

#pragma mark - Logs -

- (BOOL)saveLogMetadata:(NSDictionary *)rawLogMetadata forBuild:(BRBuild *)build error:(NSError * __autoreleasing *)error {
    return [self.logStorage saveLogMetadata:rawLogMetadata forBuild:build error:error];
}

- (BOOL)appendLogs:(NSString *)text chunkPosition:(NSUInteger)chunkPosition toBuild:(BRBuild *)build error:(NSError * __autoreleasing *)error {
    return [self.logStorage appendLogs:text chunkPosition:chunkPosition toBuild:build error:error];
}

- (BOOL)markBuildLog:(BRBuildLog *)buildLog loaded:(BOOL)isLoaded error:(NSError * __autoreleasing *)error {
    return [self.logStorage markBuildLog:buildLog loaded:isLoaded error:error];
}

- (BOOL)cleanLogs:(BRBuild *)build error:(NSError * __autoreleasing *)error {
    return [self.logStorage cleanLogs:build error:error];
}

#pragma mark - Save -

- (BOOL)saveContext:(NSManagedObjectContext *)context error:(NSError * __autoreleasing *)error {
    if ([context hasChanges]) {
        [context processPendingChanges];
        return [context save:error];
    }
    
    return YES;
}

@end
