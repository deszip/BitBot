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

@interface ASLogLoadingOperation () <NSURLSessionDownloadDelegate>

@property (strong, nonatomic) BRStorage *storage;
@property (strong, nonatomic) BRBitriseAPI *api;
@property (copy, nonatomic) NSString *buildSlug;

@property (strong, nonatomic) NSURLSession *session;

@end

@implementation ASLogLoadingOperation

- (instancetype)initWithStorage:(BRStorage *)storage api:(BRBitriseAPI *)api buildSlug:(NSString *)buildSlug {
    if (self = [super init]) {
        _storage = storage;
        _api = api;
        _buildSlug = buildSlug;
        
        self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:self.queue];
    }
    
    return self;
}


- (void)start {
    [super start];

    [self.storage perform:^{
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
        
        // Clean previous logs
        // If we have multiple chunks and log was archived - assume we dont have full log
        if (build.log.chunks.count > 1 && build.log.archived) {
            NSError *cleanError;
            if (![self.storage cleanLogs:build error:&cleanError]) {
                [super finish];
                return;
            }
        }
        
        // Load full log for evrybody else
        [self loadLogs:build];
    }];
}

- (void)loadLogs:(BRBuild *)build {
    NSLog(@"ASLogLoadingOperation: fetching log: %@", self.buildSlug);
    BRLogsRequest *request = [[BRLogsRequest alloc] initWithToken:build.app.account.token
                                                          appSlug:build.app.slug
                                                        buildSlug:build.slug since:[build.log.timestamp timeIntervalSince1970]];
    [self.api loadLogs:request completion:^(NSDictionary *rawLog, NSError *error) {
        if (rawLog) {
            NSError *saveError;
            [self.storage saveLogs:rawLog forBuild:build error:&saveError];
            
            // Remove chunks
            [build.log setChunks:[NSSet set]];
            
            NSURL *logURL = [NSURL URLWithString:build.log.expiringRawLogURL];
            if (logURL) {
                NSURLSessionDownloadTask *task = [self.session downloadTaskWithURL:logURL completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                    NSError *readingError;
                    NSError *saveError;
                    NSString *logContent = [NSString stringWithContentsOfFile:location.path encoding:NSUTF8StringEncoding error:&readingError];
                    BOOL logSaved = [self.storage addChunkToBuild:build withText:logContent error:&saveError];
                    if (logContent && logSaved) {
                        NSLog(@"ASLogLoadingOperation: %@ - log saved", self.buildSlug);
                    } else {
                        NSLog(@"ASLogLoadingOperation: Read log : %@\nSave log : %@", readingError, saveError);
                    }
                    [super finish];
                }];
                [task resume];
            }
        }
    }];
}

#pragma mark - NSURLSessionDownloadDelegate -

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSLog(@"ASLogLoadingOperation: %@ - %lld / %lld", self.buildSlug, totalBytesWritten, totalBytesExpectedToWrite);
}

@end
