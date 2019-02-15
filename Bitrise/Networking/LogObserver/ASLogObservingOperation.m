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
#import "NSArray+FRP.h"

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
    
    [self.storage perform:^{
        NSError *error;
        if (![self.storage cleanLogs:self.buildSlug error:&error]) {
            [super finish];
            return;
        }
        
        //[self schedulePoll];
    }];
    
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

- (void)schedulePoll {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kPollTimeout
                                                  target:self
                                                selector:@selector(fetchLogs)
                                                userInfo:nil
                                                 repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    [[NSRunLoop currentRunLoop] run];
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
                [self.storage saveLogMetadata:rawLog forBuild:build error:&saveError];
                
                NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey: @"position"
                                                                            ascending:YES];
                NSArray *chunks = [rawLog[@"log_chunks"] sortedArrayUsingDescriptors: @[sortDescriptor]];
                NSArray *lines = [chunks aps_map:^NSString *(NSDictionary *chunk) {
                    return chunk[@"chunk"];
                }];
                NSString *logContent = [lines componentsJoinedByString:@""];
                [self.storage appendLogs:logContent toBuild:build error:&saveError];
                
                NSLog(@"ASLogObservingOperation: got build log, lines: %lu", build.log.lines.count);
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
