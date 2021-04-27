//
//  BRSyncOperation.m
//  BitBot
//
//  Created by Deszip on 08/12/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRSyncOperation.h"

#import <Sentry/Sentry.h>
#import "BRLogger.h"
#import "BRMacro.h"

#import "NSArray+FRP.h"
#import "BRBuild+CoreDataClass.h"
#import "BRSyncDiff.h"

#import "BRAppsRequest.h"
#import "BRBuildsRequest.h"
#import "BRBuildInfo.h"

typedef void (^AppSyncCompletion)(NSError * _Nullable error);

@interface BRSyncOperation ()

@property (assign, nonatomic) NSUInteger accountsCount;
@property (assign, nonatomic) NSUInteger appsCount;

@property (strong, nonatomic) BRStorage *storage;
@property (strong, nonatomic) BRBitriseAPI *api;

@property (strong, nonatomic) dispatch_group_t group;

@end

@implementation BRSyncOperation

- (instancetype)initWithStorage:(BRStorage *)storage api:(BRBitriseAPI *)api {
    if (self = [super init]) {
        _storage = storage;
        _api = api;
        _accountsCount = 0;
        _appsCount = 0;
    }
    
    return self;
}

- (void)start {
    [super start];
    
    self.group = dispatch_group_create();
    
    [self.storage perform:^{
        NSError *accFetchError;
        NSArray <BTRAccount *> *accounts = [self.storage accounts:&accFetchError];

        if (!accounts) {
            BRLog(LL_DEBUG, LL_STORAGE, @"Failed to get accounts: %@", accFetchError);
            [self finish];
            return;
        }
        
        if (accounts.count == 0) {
            BRLog(LL_DEBUG, LL_STORAGE, @"No accounts, nothing to do...");
            [self finish];
            return;
        }
        
        self.accountsCount = accounts.count;
        
        [accounts enumerateObjectsUsingBlock:^(BTRAccount *account, NSUInteger idx, BOOL *stop) {
            dispatch_group_enter(self.group);
            id<SentrySpan> accountSpan = [self.sentryTransaction startChildWithOperation:[NSString stringWithFormat:@"account-sync-%lu", (unsigned long)idx]];
            
            BRAppsRequest *appsRequest = [[BRAppsRequest alloc] initWithToken:account.token];
            [self.api getApps:appsRequest completion:^(NSArray<BRAppInfo *> *appsInfo, NSError *error) {
                // Handle failure
                if (!appsInfo) {
                    BRLog(LL_WARN, LL_STORAGE, @"Failed to get apps from API: %@", error);
                    
                    // 401 means acc is not working for some reason
                    if ([error.domain isEqualToString:kBRBitriseAPIDomain] && error.code == 401 && account.enabled) {
                        NSError *updateError;
                        if ([self.storage updateAccountStatus:NO slug:account.slug error:&updateError]) {
                            BRLog(LL_WARN, LL_STORAGE, @"Account %@ disabled", account.email);
                        } else {
                            BRLog(LL_WARN, LL_STORAGE, @"Failed to disable account: %@", updateError);
                        }
                    }
                    [accountSpan finish];
                    dispatch_group_leave(self.group);
                    return;
                }
                
                // Enable acc if it works fine
                if (!account.enabled) {
                    NSError *updateError;
                    if ([self.storage updateAccountStatus:YES slug:account.slug error:&updateError]) {
                        BRLog(LL_WARN, LL_STORAGE, @"Account %@ enabled", account.email);
                    } else {
                        BRLog(LL_WARN, LL_STORAGE, @"Failed to enable account: %@", updateError);
                    }
                }
                
                // Updates
                NSError *updateAppsError;
                if (![self.storage updateApps:appsInfo forAccount:account error:&updateAppsError]) {
                    BRLog(LL_WARN, LL_STORAGE, @"Failed to update apps: %@", updateAppsError);
                    [accountSpan finish];
                    dispatch_group_leave(self.group);
                    return;
                }
                
                NSError *appsFetchError;
                NSArray <BRApp *> *apps = [self.storage appsForAccount:account error:&appsFetchError];
                if (!apps) {
                    BRLog(LL_WARN, LL_STORAGE, @"Failed to fetch updated apps: %@", appsFetchError);
                    [accountSpan finish];
                    dispatch_group_leave(self.group);
                    return;
                }
                
                [accountSpan.context setTagValue:[NSString stringWithFormat:@"%lu", (unsigned long)apps.count] forKey:@"apps"];
                
                NSError *fetchError;
                NSArray <NSString *> *runningBuildSlugs = [[self.storage runningBuilds:&fetchError] aps_map:^id(BRBuild *build) {
                    return build.slug;
                }];
                [apps enumerateObjectsUsingBlock:^(BRApp *app, NSUInteger idx, BOOL *stop) {
                    id<SentrySpan> appSpan = [accountSpan startChildWithOperation:[NSString stringWithFormat:@"app-sync-%lu", (unsigned long)idx]];
                    [self updateBuilds:app token:account.token runningBuilds:runningBuildSlugs completion:^(NSError *error) {
                        [appSpan finish];
                    }];
                }];
               
                [accountSpan finish];
                dispatch_group_leave(self.group);
            }];
        }];
        
        dispatch_group_notify(self.group, self.queue.underlyingQueue, ^{
            [self finish];
        });
    }];
}

- (void)finish {
    [self.sentryTransaction.context setTagValue:[NSString stringWithFormat:@"%lu", (unsigned long)self.accountsCount] forKey:@"accounts"];
    [super finish];
}

- (NSTimeInterval)fetchTime:(BRApp *)app {
    BRBuild *latestBuild = [self.storage latestBuild:app error:NULL];
    NSTimeInterval fetchTime = latestBuild ? [latestBuild.triggerTime timeIntervalSince1970] - 1 : 0;
    
    return fetchTime;
}

- (void)updateBuilds:(BRApp *)app token:(NSString *)token runningBuilds:(NSArray <NSString *> *)runningBuildSlugs completion:(AppSyncCompletion)completion {
    dispatch_group_enter(self.group);
    
    NSTimeInterval fetchTime = [self fetchTime:app];
    BRBuildsRequest *request = [[BRBuildsRequest alloc] initWithToken:token appSlug:app.slug syncTime:fetchTime];
    
    [self.api getBuilds:request completion:^(NSArray<BRBuildInfo *> *builds, NSError *error) {
        if (builds) {
            // Populate builds with app name
            [builds enumerateObjectsUsingBlock:^(BRBuildInfo *build, NSUInteger idx, BOOL *stop) {
                build.appName = app.title;
            }];
            
            // Run sync
            if (self.syncCallback) {
                BRSyncDiff *diff = [self diffForBuilds:builds runningBuilds:runningBuildSlugs];
                BRAppInfo *appInfo = [[BRAppInfo alloc] initWithApp:app];
                BRSyncResult *result = [[BRSyncResult alloc] initWithApp:appInfo diff:diff];
                self.syncCallback(result);
            }
            if (![self.storage saveBuilds:builds forApp:app.slug error:&error]) {
                BRLog(LL_WARN, LL_STORAGE, @"Failed to save builds: %@", error);
            }
        } else {
            BRLog(LL_WARN, LL_STORAGE, @"Failed to get builds from API: %@", error);
        }
        
        BR_SAFE_CALL(completion, error);
        dispatch_group_leave(self.group);
    }];
}

- (BRSyncDiff *)diffForBuilds:(NSArray <BRBuildInfo *> *)remoteBuilds runningBuilds:(NSArray <NSString *> *)runningBuilds {
    __block NSMutableArray <BRBuildInfo *> *finished = [NSMutableArray array];
    __block NSMutableArray <BRBuildInfo *> *running = [NSMutableArray array];
    __block NSMutableArray <BRBuildInfo *> *started = [NSMutableArray array];
    [remoteBuilds enumerateObjectsUsingBlock:^(BRBuildInfo *remoteBuild, NSUInteger idx, BOOL *stop) {
        if ([runningBuilds containsObject:remoteBuild.slug]) {
            if (remoteBuild.stateInfo.state != BRBuildStateHold && remoteBuild.stateInfo.state != BRBuildStateInProgress) {
                BRLog(LL_DEBUG, LL_CORE, @"Finished build: %@", remoteBuild.slug);
                [finished addObject:remoteBuild];
            }
            if (remoteBuild.stateInfo.state == BRBuildStateInProgress) {
                BRLog(LL_DEBUG, LL_CORE, @"Running build: %@", remoteBuild.slug);
                [running addObject:remoteBuild];
            }
        } else {
            if (remoteBuild.stateInfo.state == BRBuildStateHold || remoteBuild.stateInfo.state == BRBuildStateInProgress) {
                BRLog(LL_DEBUG, LL_CORE, @"Started build: %@", remoteBuild.slug);
                [started addObject:remoteBuild];
            }
        }
    }];
    
    return [[BRSyncDiff alloc] initWithStartedBuilds:started runningBuilds:running finishedBuilds:finished];
}

@end
