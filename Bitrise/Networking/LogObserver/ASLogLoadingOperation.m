//
//  ASLogLoadingOperation.m
//  Bitrise
//
//  Created by Deszip on 08/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "ASLogLoadingOperation.h"

#import "BRLogger.h"

#import "BRMacro.h"
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
    
    BR_SAFE_CALL(self.loadingCallback, BRLogLoadingStateStarted, nil);
    
    [self.storage perform:^{
        NSError *fetchError;
        BRBuild *build = [self.storage buildWithSlug:self.buildSlug error:&fetchError];
        if (!build) {
            BRLog(LL_WARN, LL_STORAGE, @"ASLogLoadingOperation: failed to get build: %@", fetchError);
            [self finish];
            return;
        }
        
        BRBuildStateInfo *stateInfo = [[BRBuildInfo alloc] initWithBuild:build].stateInfo;
        
        // Ignore not started and running builds, we should have observing op. for them
        if (stateInfo.state == BRBuildStateInProgress ||
            stateInfo.state == BRBuildStateHold) {
            [self finish];
            return;
        }
        
        // Skip fully loaded
        if (build.log.loaded) {
            [self finish];
            return;
        }
        
        // Load full log for evrybody else
        [self loadLogs:build];
    }];
}

- (void)finish {
    BR_SAFE_CALL(self.loadingCallback, BRLogLoadingStateFinished, nil);
    [super finish];
}

- (void)loadLogs:(BRBuild *)build {
    BRLog(LL_DEBUG, LL_STORAGE, @"ASLogLoadingOperation: fetching log: %@", self.buildSlug);
    BRLogsRequest *request = [[BRLogsRequest alloc] initWithToken:build.app.account.token
                                                          appSlug:build.app.slug
                                                        buildSlug:build.slug since:[build.log.timestamp timeIntervalSince1970]];
    [self.api loadLogs:request completion:^(BRLogInfo *logInfo, NSError *error) {
        if (!logInfo.logURL) {
            [self finish];
            return;
        }
        
        NSURLSessionDownloadTask *task = [self.session downloadTaskWithURL:logInfo.logURL completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {

            // Move log file to app directory
            NSURL *logFileURL = [self moveLogFile:location];
            if (!logFileURL) {
                [self finish];
                return;
            }
            
            [self.storage perform:^{
                NSError *cleanError;
                NSError *metadataError;
                NSError *readingError;
                NSError *saveError;
                NSError *markError;
             
                // Clean pervious logs
                if (![self.storage cleanLogs:build error:&cleanError]) {
                    BRLog(LL_WARN, LL_STORAGE, @"Failed to clean build logs: %@", cleanError);
                    [self finish];
                    return;
                }
                
                // Save log
                BOOL metadataSaved = [self.storage saveLogMetadata:logInfo.rawLog forBuild:build error:&metadataError];
                NSString *logContent = [NSString stringWithContentsOfFile:logFileURL.path encoding:NSUTF8StringEncoding error:&readingError];
                BOOL logSaved = [self.storage appendLogs:logContent chunkPosition:0 toBuild:build error:&saveError];
                BOOL logMarked = [self.storage markBuildLog:build.log loaded:YES error:&markError];
                
                if (metadataSaved && logSaved && logMarked) {
                    BRLog(LL_DEBUG, LL_STORAGE, @"ASLogLoadingOperation: %@ - log saved", self.buildSlug);
                } else {
                    BRLog(LL_DEBUG, LL_STORAGE, @"ASLogLoadingOperation: Read log : %@\nSave log : %@\nMark loaded: %@", readingError, saveError, markError);
                }
                
                [self finish];
            }];
        }];
        [task resume];
        BR_SAFE_CALL(self.loadingCallback, BRLogLoadingStateInProgress, task.progress);
    }];
}

#pragma mark - Tools -

- (NSURL *)moveLogFile:(NSURL *)tmpURL {
    NSError *moveError;
    NSURL *targetURL = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&moveError];
    targetURL = [targetURL URLByAppendingPathComponent:tmpURL.lastPathComponent];
    BOOL moveResult = [[NSFileManager defaultManager] moveItemAtURL:tmpURL toURL:targetURL error:&moveError];
    if (!moveResult) {
        BRLog(LL_WARN, LL_STORAGE, @"Failed to move log file: %@", moveError);
        [super finish];
        return nil;
    }
    
    return targetURL;
}

#pragma mark - NSURLSessionDownloadDelegate -

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSLog(@"ASLogLoadingOperation: %@ - %lld / %lld", self.buildSlug, totalBytesWritten, totalBytesExpectedToWrite);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {}

@end
