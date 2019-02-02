//
//  ASLogLoadingOperation.m
//  Bitrise
//
//  Created by Deszip on 02/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "ASLogLoadingOperation.h"

#import "BRBuild+CoreDataClass.h"
#import "BRLogsRequest.h"

static const NSTimeInterval kPollTimeout = 1.0;

@interface ASLogLoadingOperation ()

@property (strong, nonatomic) BRStorage *storage;
@property (strong, nonatomic) BRBitriseAPI *api;

@property (strong, nonatomic) NSTimer *timer;

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
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kPollTimeout
                                                  target:self
                                                selector:@selector(fetchLogs)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)finish {
    [self.timer invalidate];
    [super finish];
}

- (void)fetchLogs {
    NSLog(@"ASLogLoadingOperation: fetching log: %@", self.buildSlug);
    
    NSError *fetchError;
    BRBuild *build = [self.storage buildWithSlug:self.buildSlug error:&fetchError];
    if (!build) {
        NSLog(@"ASLogLoadingOperation: failed to get build: %@", fetchError);
        [self finish];
        return;
    }

    NSLog(@"ASLogLoadingOperation: got build: %@", build);
    
    BRLogsRequest *request = [[BRLogsRequest alloc] initWithToken:build.app.account.token
                                                          appSlug:build.app.slug
                                                        buildSlug:build.slug];
    [self.api loadLogs:request completion:^(NSDictionary *rawLog, NSError *error) {
        if (rawLog) {
            NSLog(@"ASLogLoadingOperation: got build log: %@", rawLog);
            NSError *saveError;
            [self.storage saveLogs:rawLog forBuild:build error:&saveError];
        }
        
        BRBuildStateInfo *buildInfo = [[BRBuildStateInfo alloc] initWithBuildStatus:build.status.integerValue
                                                                         holdStatus:build.onHold.boolValue];
        if (buildInfo.state == BRBuildStateSuccess ||
            buildInfo.state == BRBuildStateFailed ||
            buildInfo.state == BRBuildStateAborted) {
            NSLog(@"ASLogLoadingOperation: build finished");
            [self finish];
        }
    }];
}

@end
