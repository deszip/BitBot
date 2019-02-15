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
@property (strong, nonatomic) NSOperationQueue *urlSessionQueue;

@end

@implementation ASLogLoadingOperation

- (instancetype)initWithStorage:(BRStorage *)storage api:(BRBitriseAPI *)api buildSlug:(NSString *)buildSlug {
    if (self = [super init]) {
        _storage = storage;
        _api = api;
        _buildSlug = buildSlug;
        
        _urlSessionQueue = [NSOperationQueue new];
        [_urlSessionQueue setMaxConcurrentOperationCount:1];
        
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
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
        
        // Ignore not started and running builds
        if (stateInfo.state == BRBuildStateInProgress ||
            stateInfo.state == BRBuildStateHold) {
            [super finish];
            return;
        }
        
        // If we have at least one line, log is archived and we have no last timestamp - assume we have full log
        if (build.log.loaded) {
            [super finish];
            return;
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
            NSError *cleanError;
            if (![self.storage cleanLogs:build.slug error:&cleanError]) {
                NSLog(@"Failed to clean build logs: %@", cleanError);
                [super finish];
                return;
            }
            
            NSError *saveError;
            [self.storage saveLogMetadata:rawLog forBuild:build error:&saveError];
            
            NSURL *logURL = [NSURL URLWithString:build.log.expiringRawLogURL];
            if (logURL) {
                NSURLSessionDownloadTask *task = [self.session downloadTaskWithURL:logURL completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                    [self.storage perform:^{
                        NSError *readingError;
                        NSError *saveError;
                        NSError *markError;
                        NSString *logContent = [NSString stringWithContentsOfFile:location.path encoding:NSUTF8StringEncoding error:&readingError];
                        BOOL logSaved = [self.storage appendLogs:logContent toBuild:build error:&saveError];
                        
                        if (logContent && logSaved && [self.storage markBuildLog:build.log loaded:YES error:&markError]) {
                            NSLog(@"ASLogLoadingOperation: %@ - log saved", self.buildSlug);
                        } else {
                            NSLog(@"ASLogLoadingOperation: Read log : %@\nSave log : %@\nMark loaded: %@", readingError, saveError);
                        }
                        [super finish];
                    }];
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

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {}

@end
