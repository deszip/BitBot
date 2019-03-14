//
//  BRSyncOperation.m
//  BitBot
//
//  Created by Deszip on 08/12/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRSyncOperation.h"

//#import "ASTracer.h"
#import "BRBuildStateInfo.h"
#import "NSArray+FRP.h"
#import "BRBuild+CoreDataClass.h"
#import "BRSyncDiff.h"

#import "BRAppsRequest.h"
#import "BRBuildsRequest.h"

@interface BRSyncOperation ()

@property (strong, nonatomic) BRStorage *storage;
@property (strong, nonatomic) BRBitriseAPI *api;

@property (strong, nonatomic) dispatch_group_t group;

@end

@implementation BRSyncOperation

- (instancetype)initWithStorage:(BRStorage *)storage api:(BRBitriseAPI *)api {
    if (self = [super init]) {
        _storage = storage;
        _api = api;
    }
    
    return self;
}

- (void)start {
    [super start];
    
    self.group = dispatch_group_create();
    
    [self.storage perform:^{
        
        //NSString *scopeName = [NSString stringWithFormat:@"%@", self.queue];
        //[[ASTracer tracer] startSpan:@"Accounts fetch" inScope:scopeName];
        
        NSError *accFetchError;
        NSArray <BRAccount *> *accounts = [self.storage accounts:&accFetchError];
        if (!accounts) {
            NSLog(@"Failed to get accounts: %@", accFetchError);
            [super finish];
            return;
        }
        
        if (accounts.count == 0) {
            NSLog(@"No accounts, nothing to do...");
            [super finish];
            return;
        }
        
        //[[ASTracer tracer] stopSpan:@"Accounts fetch" inScope:scopeName sucess:YES];
        
        [accounts enumerateObjectsUsingBlock:^(BRAccount *account, NSUInteger idx, BOOL *stop) {
            
            dispatch_group_enter(self.group);
            
            //[[ASTracer tracer] startSpan:[NSString stringWithFormat:@"acc fetch: %@", account.slug] inScope:scopeName];
            
            BRAppsRequest *appsRequest = [[BRAppsRequest alloc] initWithToken:account.token];
            [self.api getApps:appsRequest completion:^(NSArray<BRAppInfo *> *appsInfo, NSError *error) {
                
                //[[ASTracer tracer] stopSpan:[NSString stringWithFormat:@"acc fetch: %@", account.slug] inScope:scopeName sucess:YES];
                
                //NSString *spanName = [NSString stringWithFormat:@"acc update: %@", account.slug];
                //[[ASTracer tracer] startSpan:spanName inScope:scopeName];
                
                if (!appsInfo) {
                    NSLog(@"Failed to get apps from API: %@", error);
                    //[[ASTracer tracer] stopSpan:spanName inScope:scopeName sucess:NO];
                    [super finish];
                    return;
                }
                
                NSError *updateAppsError;
                if (![self.storage updateApps:appsInfo forAccount:account error:&updateAppsError]) {
                    NSLog(@"Failed to update apps: %@", updateAppsError);
                    //[[ASTracer tracer] stopSpan:spanName inScope:scopeName sucess:NO];
                    [super finish];
                    return;
                }
                
                NSError *appsFetchError;
                NSArray <BRApp *> *apps = [self.storage appsForAccount:account error:&appsFetchError];
                if (!apps) {
                    NSLog(@"Failed to fetch updated apps: %@", appsFetchError);
                    //[[ASTracer tracer] stopSpan:spanName inScope:scopeName sucess:NO];
                    [super finish];
                    return;
                }

                NSError *fetchError;
                NSArray <NSString *> *runningBuildSlugs = [[self.storage runningBuilds:&fetchError] aps_map:^id(BRBuild *build) {
                    return build.slug;
                }];
                [apps enumerateObjectsUsingBlock:^(BRApp *app, NSUInteger idx, BOOL *stop) {
                    [self updateBuilds:app token:account.token runningBuilds:runningBuildSlugs];
                }];
                
                //[[ASTracer tracer] stopSpan:spanName inScope:scopeName sucess:YES];
                
                dispatch_group_leave(self.group);
            }];
        }];
        
        dispatch_group_notify(self.group, self.queue.underlyingQueue, ^{
            [super finish];
        });
    }];
}

- (NSTimeInterval)fetchTime:(BRApp *)app {
    BRBuild *latestBuild = [self.storage latestBuild:app error:NULL];
    NSTimeInterval fetchTime = latestBuild ? [latestBuild.triggerTime timeIntervalSince1970] - 1 : 0;
    
    return fetchTime;
}

- (void)updateBuilds:(BRApp *)app token:(NSString *)token runningBuilds:(NSArray <NSString *> *)runningBuildSlugs {
    dispatch_group_enter(self.group);
    
    NSTimeInterval fetchTime = [self fetchTime:app];
    BRBuildsRequest *request = [[BRBuildsRequest alloc] initWithToken:token appSlug:app.slug syncTime:fetchTime];
    
    [self.api getBuilds:request completion:^(NSArray<BRBuildInfo *> *builds, NSError *error) {
        if (builds) {
            if (self.syncCallback) {
                BRSyncDiff *diff = [self diffForBuilds:builds runningBuilds:runningBuildSlugs];
                BRAppInfo *appInfo = [[BRAppInfo alloc] initWithApp:app];
                BRSyncResult *result = [[BRSyncResult alloc] initWithApp:appInfo diff:diff];
                self.syncCallback(result);
            }
            if (![self.storage saveBuilds:builds forApp:app.slug error:&error]) {
                NSLog(@"Failed to save builds: %@", error);
            }
        } else {
            NSLog(@"Failed to get builds from API: %@", error);
        }
        
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
                NSLog(@"Finished build: %@", remoteBuild.slug);
                [finished addObject:remoteBuild];
            }
            if (remoteBuild.stateInfo.state == BRBuildStateInProgress) {
                NSLog(@"Running build: %@", remoteBuild.slug);
                [running addObject:remoteBuild];
            }
        } else {
            if (remoteBuild.stateInfo.state == BRBuildStateHold || remoteBuild.stateInfo.state == BRBuildStateInProgress) {
                NSLog(@"Started build: %@", remoteBuild.slug);
                [started addObject:remoteBuild];
            }
        }
    }];
    
    return [[BRSyncDiff alloc] initWithStartedBuilds:started runningBuilds:running finishedBuilds:finished];
}

@end
