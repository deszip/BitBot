//
//  BRCommandFactory.m
//  Bitrise
//
//  Created by Deszip on 20.06.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

#import "BRCommandFactory.h"

@interface BRCommandFactory ()

@property (strong, nonatomic) BRBitriseAPI *api;
@property (strong, nonatomic) BRSyncEngine *syncEngine;
@property (strong, nonatomic) BREnvironment *environment;

@end

@implementation BRCommandFactory

- (instancetype)initWithAPI:(BRBitriseAPI *)api
                 syncEngine:(BRSyncEngine *)syncEngine
                environment:(BREnvironment *)environment {
    if (self = [super init]) {
        _api = api;
        _syncEngine = syncEngine;
        _environment = environment;
    }
    
    return self;
}

- (BRRebuildCommand *)rebuildCommand:(BRBuild *)build {
    return [[BRRebuildCommand alloc] initWithAPI:self.api build:build];
}

- (BRAbortCommand *)abortCommand:(BRBuild *)build {
    return [[BRAbortCommand alloc] initWithAPI:self.api build:build];
}

- (BRDownloadLogsCommand *)logsCommand:(NSString *)buildSlug {
    return [[BRDownloadLogsCommand alloc] initWithBuildSlug:buildSlug];
}

- (BROpenBuildCommand *)openCommand:(NSString *)buildSlug {
    return [[BROpenBuildCommand alloc] initWithBuildSlug:buildSlug];
}

- (BRSyncCommand *)syncCommand {
    return [[BRSyncCommand alloc] initSyncEngine:self.syncEngine environment:self.environment];
}

@end
