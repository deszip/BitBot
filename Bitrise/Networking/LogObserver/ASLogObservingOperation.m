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
#import "BRLogInfo.h"

static const NSTimeInterval kPollTimeout = 1.0;

@interface ASLogObservingOperation ()

@property (strong, nonatomic) BRStorage *storage;
@property (strong, nonatomic) BRBitriseAPI *api;

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSMutableIndexSet *receivedChunks;

@end

@implementation ASLogObservingOperation

- (instancetype)initWithStorage:(BRStorage *)storage api:(BRBitriseAPI *)api buildSlug:(NSString *)buildSlug {
    if (self = [super init]) {
        _storage = storage;
        _api = api;
        _buildSlug = buildSlug;
        _receivedChunks = [NSMutableIndexSet indexSet];
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
        
        // ?
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
        
        NSError *fetchError;
        BRBuild *build = [self.storage buildWithSlug:self.buildSlug error:&fetchError];
        if (!build) {
            NSLog(@"ASLogObservingOperation: failed to get build: %@", fetchError);
            [self finish];
            return;
        }
        
        NSTimeInterval fetchTime = [build.log.timestamp timeIntervalSince1970];
        BRLogsRequest *request = [[BRLogsRequest alloc] initWithToken:build.app.account.token
                                                              appSlug:build.app.slug
                                                            buildSlug:build.slug since:fetchTime];
        NSLog(@"ASLogObservingOperation: %@, request timestamp: %f", self, fetchTime);
        [self.api loadLogs:request completion:^(BRLogInfo *logInfo, NSError *error) {
            if (logInfo.rawLog) {
                NSError *saveError;
                [self.storage saveLogMetadata:logInfo.rawLog forBuild:build error:&saveError];
                NSArray *chunks = [logInfo chunksExcluding:self.receivedChunks];
                [chunks enumerateObjectsUsingBlock:^(NSDictionary *chunk, NSUInteger idx, BOOL *stop) {
                    NSError *appendError;
                    [self.storage appendLogs:chunk[@"chunk"] chunkPosition:[chunk[@"position"] integerValue] toBuild:build error:&appendError];
                }];
                
                [self.receivedChunks addIndexes:[logInfo chunkPositions]];
                
                NSLog(@"ASLogObservingOperation: got chunks: %lu, filtered: %lu", [logInfo.rawLog[@"log_chunks"] count], chunks.count);
                NSLog(@"ASLogObservingOperation: got timestamp: %@", logInfo.rawLog[@"timestamp"]);
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
