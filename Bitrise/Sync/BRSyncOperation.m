//
//  BRSyncOperation.m
//  Bitrise
//
//  Created by Deszip on 08/12/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BRSyncOperation.h"

#import "BRBuild+CoreDataClass.h"

@interface BRSyncOperation ()

@property (strong, nonatomic) BRStorage *storage;
@property (strong, nonatomic) BRBitriseAPI *api;

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

    NSLog(@"Start sync...");
    
    [self.storage perform:^{
        NSError *accFetchError;
        NSArray <BRAccount *> *accounts = [self.storage accounts:&accFetchError];
        if (!accounts) {
            NSLog(@"Failed to get accounts: %@", accFetchError);
            [super finish];
            return;
        }
        
        [accounts enumerateObjectsUsingBlock:^(BRAccount *account, NSUInteger idx, BOOL *stop) {
            NSLog(@"Got %lu accounts", (unsigned long)accounts.count);
            [self.api getApps:account.token completion:^(NSArray<BRAppInfo *> *appsInfo, NSError *error) {
                if (!appsInfo) {
                    NSLog(@"Failed to get apps from API: %@", error);
                    [super finish];
                    return;
                }
                
                NSError *updateAppsError;
                if (![self.storage updateApps:appsInfo forAccount:account error:&updateAppsError]) {
                    NSLog(@"Failed to update apps: %@", updateAppsError);
                    [super finish];
                    return;
                }
                
                NSError *appsFetchError;
                NSArray <BRApp *> *apps = [self.storage appsForAccount:account error:&appsFetchError];
                if (!apps) {
                    NSLog(@"Failed to fetch updated apps: %@", appsFetchError);
                    [super finish];
                    return;
                }
                
                [apps enumerateObjectsUsingBlock:^(BRApp *app, NSUInteger idx, BOOL *stop) {
                    [self updateBuilds:app token:account.token];
                }];
            }];
        }];
    }];
}

- (NSTimeInterval)fetchTime:(BRApp *)app {
    BRBuild *latestBuild = [self.storage latestBuild:app error:NULL];
    NSTimeInterval fetchTime = latestBuild ? [latestBuild.triggerTime timeIntervalSince1970] + 1 : 0;
    
    return fetchTime;
}

- (void)updateBuilds:(BRApp *)app token:(NSString *)token {
    NSTimeInterval fetchTime = [self fetchTime:app];
    [self.api getBuilds:app.slug token:token after:fetchTime completion:^(NSArray<BRBuildInfo *> *builds, NSError *error) {
        if (builds) {
            NSLog(@"Got builds for app: %@, count: %lu, after: %f", app.slug, (unsigned long)builds.count, fetchTime);
            if (![self.storage saveBuilds:builds forApp:app.slug error:&error]) {
                NSLog(@"Failed to save builds: %@", error);
            }
        } else {
            NSLog(@"Failed to get builds from API: %@", error);
        }
        
        [super finish];
    }];
}

@end
