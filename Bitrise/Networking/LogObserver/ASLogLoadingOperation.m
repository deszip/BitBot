//
//  ASLogLoadingOperation.m
//  Bitrise
//
//  Created by Deszip on 08/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "ASLogLoadingOperation.h"

#import "ASLogObservingOperation.h"
#import "BRBuildInfo.h"
#import "BRBuild+CoreDataClass.h"
#import "BRBuildLog+CoreDataClass.h"
#import "BRLogsRequest.h"

@interface ASLogLoadingOperation ()

@property (strong, nonatomic) BRStorage *storage;
@property (strong, nonatomic) BRBitriseAPI *api;
@property (copy, nonatomic) NSString *buildSlug;

@end

@implementation ASLogLoadingOperation

- (instancetype)initWithStorage:(BRStorage *)storage api:(BRBitriseAPI *)api buildSlug:(NSString *)buildSlug {
    if (self = [super init]) {
        _storage = storage;
        _api = api;
        _buildSlug = buildSlug;
    }
    
    return self;
}


- (void)start {
    [super start];

    [self.storage perform:^{
        NSLog(@"ASLogLoadingOperation: fetching log: %@", self.buildSlug);
        
        NSError *fetchError;
        BRBuild *build = [self.storage buildWithSlug:self.buildSlug error:&fetchError];
        if (!build) {
            NSLog(@"ASLogLoadingOperation: failed to get build: %@", fetchError);
            [self finish];
            return;
        }
        
        BRBuildStateInfo *stateInfo = [[BRBuildInfo alloc] initWithBuild:build].stateInfo;
        
        // Dispatch observing op. for running build
        if (stateInfo.state == BRBuildStateInProgress) {
            ASLogObservingOperation *observingOperation = [[ASLogObservingOperation alloc] initWithStorage:self.storage api:self.api buildSlug:self.buildSlug];
            [self.queue addOperation:observingOperation];
            [super finish];
            return;
        }
        
        // Ignore not started build
        if (stateInfo.state == BRBuildStateHold) {
            [super finish];
            return;
        }
        
        // Load full log for evrybody else
        [self loadLogs:build];
    }];
}

- (void)loadLogs:(BRBuild *)build {
    BRLogsRequest *request = [[BRLogsRequest alloc] initWithToken:build.app.account.token
                                                          appSlug:build.app.slug
                                                        buildSlug:build.slug since:[build.log.timestamp timeIntervalSince1970]];
    [self.api loadLogs:request completion:^(NSDictionary *rawLog, NSError *error) {
        if (rawLog) {
            NSError *saveError;
            [self.storage saveLogs:rawLog forBuild:build error:&saveError];
            
            // load build.log.expiringRawLogURL
            //...
        }
        
    }];
}

@end
