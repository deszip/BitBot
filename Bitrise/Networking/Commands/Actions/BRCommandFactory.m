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
#if TARGET_OS_OSX
@property (strong, nonatomic) BREnvironment *environment;
#endif

@end

@implementation BRCommandFactory

#if TARGET_OS_OSX
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
#else

- (instancetype)initWithAPI:(BRBitriseAPI *)api
                 syncEngine:(BRSyncEngine *)syncEngine {
    if (self = [super init]) {
        _api = api;
        _syncEngine = syncEngine;
    }
    
    return self;
}

#endif

- (BRRebuildCommand *)rebuildCommand:(BRBuild *)build {
    return [[BRRebuildCommand alloc] initWithAPI:self.api build:build];
}

- (BRAbortCommand *)abortCommand:(BRBuild *)build {
    return [[BRAbortCommand alloc] initWithAPI:self.api build:build];
}

#if TARGET_OS_OSX
- (BRDownloadLogsCommand *)logsCommand:(NSString *)buildSlug {
    return [[BRDownloadLogsCommand alloc] initWithBuildSlug:buildSlug];
}

- (BROpenBuildCommand *)openCommand:(NSString *)buildSlug tab:(BRBuildPageTab)tab {
    return [[BROpenBuildCommand alloc] initWithBuildSlug:buildSlug tab:tab environment:self.environment];
}
#endif

- (BRSyncCommand *)syncCommand {
#if TARGET_OS_OSX
    return [[BRSyncCommand alloc] initSyncEngine:self.syncEngine environment:self.environment];
#else
    return [[BRSyncCommand alloc] initSyncEngine:self.syncEngine];
#endif
}

@end
