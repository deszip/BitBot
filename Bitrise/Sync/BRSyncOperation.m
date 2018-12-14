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
    
    /*
     - get accounts from storage
        - for each account get list of apps from API
        - update apps
            - remove apps not present in response
            - add/update others
                - for each app get latest local build
                - get list of builds since last build from API
                - add/update builds
     */
    
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
                    NSError *error;
                    BRBuild *latestBuild = [self.storage latestBuild:app error:&error];
                    NSTimeInterval fetchTime = latestBuild ? [latestBuild.triggerTime timeIntervalSince1970] + 1 : 0;
                    
                    [self.api getBuilds:app.slug token:account.token after:fetchTime completion:^(NSArray<BRBuildInfo *> *builds, NSError *error) {
                        if (builds) {
                            NSLog(@"Got builds for app: %@, count: %lu, after: %f", app.slug, (unsigned long)builds.count, fetchTime);
                            if (![self.storage saveBuilds:builds forApp:app.slug error:&error]) {
                                NSLog(@"Failed to save builds: %@", error);
                            }
                            [super finish];
                        } else {
                            NSLog(@"Failed to get builds from API: %@", error);
                            [super finish];
                        }
                    }];
                    
                }];
            }];
        }];
    }];
}

@end
