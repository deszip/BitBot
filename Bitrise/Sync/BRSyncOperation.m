//
//  BRSyncOperation.m
//  Bitrise
//
//  Created by Deszip on 08/12/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BRSyncOperation.h"

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
    
    [self.storage perform:^{
        NSError *accFetchError;
        NSArray <BRAccount *> *accounts = [self.storage accounts:&accFetchError];
        if (!accounts) {
            [super finish];
            return;
        }
        
        [accounts enumerateObjectsUsingBlock:^(BRAccount *account, NSUInteger idx, BOOL *stop) {
            [self.api getApps:account.token completion:^(NSArray<BRAppInfo *> *appsInfo, NSError *error) {
                NSError *updateAppsError;
                if (![self.storage updateApps:appsInfo forAccount:account error:&updateAppsError]) {
                    [super finish];
                    return;
                }
                
                NSError *appsFetchError;
                NSArray <BRApp *> *apps = [self.storage appsForAccount:account error:&appsFetchError];
                //[self.api getBuilds:<#(nonnull BRAppInfo *)#> account:<#(nonnull BRAccountInfo *)#> completion:<#^(NSArray<BRBuildInfo *> * _Nullable, NSError * _Nullable)completion#>]
            }];
        }];
        
        [super finish];
    }];
}

@end
