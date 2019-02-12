//
//  ASLogLoadingOperation.m
//  Bitrise
//
//  Created by Deszip on 02/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "ASLogObservingOperation.h"

#import "BRBuild+CoreDataClass.h"
#import "BRBuildLog+CoreDataClass.h"
#import "BRLogsRequest.h"

static const NSTimeInterval kPollTimeout = 1.0;

@interface ASLogObservingOperation ()

@property (strong, nonatomic) BRStorage *storage;
@property (strong, nonatomic) BRBitriseAPI *api;

@property (strong, nonatomic) NSTimer *timer;

@end

@implementation ASLogObservingOperation

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
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    [[NSRunLoop currentRunLoop] run];
}

- (void)finish {
    [self.timer invalidate];
    [super finish];
}

- (void)fetchLogs {
    [self.storage perform:^{
        NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
        NSLog(@"ASLogObservingOperation: fetching log: %@", self.buildSlug);
        
        NSError *fetchError;
        BRBuild *build = [self.storage buildWithSlug:self.buildSlug error:&fetchError];
        if (!build) {
            NSLog(@"ASLogObservingOperation: failed to get build: %@", fetchError);
            [self finish];
            return;
        }
        
        BRLogsRequest *request = [[BRLogsRequest alloc] initWithToken:build.app.account.token
                                                              appSlug:build.app.slug
                                                            buildSlug:build.slug since:[build.log.timestamp timeIntervalSince1970]];
        [self.api loadLogs:request completion:^(NSDictionary *rawLog, NSError *error) {
            if (rawLog) {
                NSError *saveError;
                [self.storage saveLogs:rawLog forBuild:build error:&saveError];
                NSLog(@"ASLogObservingOperation: got build log, chunks: %lu / %lld", build.log.chunks.count, build.log.chunksCount);
            }

            if (build.log.archived) {
                NSLog(@"ASLogObservingOperation: build log archived, build finished, stopping observing...");
                [self finish];
            }
            
            NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970];
            NSLog(@"ASLogObservingOperation: fetch time: %f sec.", endTime - startTime);
        }];
    }];
}

@end
