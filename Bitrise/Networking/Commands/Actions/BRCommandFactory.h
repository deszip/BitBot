//
//  BRCommandFactory.h
//  Bitrise
//
//  Created by Deszip on 20.06.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BRBitriseAPI.h"
#import "BRSyncEngine.h"

#import "BRRebuildCommand.h"
#import "BRAbortCommand.h"
#import "BRSyncCommand.h"

#if TARGET_OS_OSX
#import "BREnvironment.h"
#import "BROpenBuildCommand.h"
#import "BRDownloadLogsCommand.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface BRCommandFactory : NSObject

#if TARGET_OS_OSX
- (instancetype)initWithAPI:(BRBitriseAPI *)api
                 syncEngine:(BRSyncEngine *)syncEngine
                environment:(BREnvironment *)environment;
#else
- (instancetype)initWithAPI:(BRBitriseAPI *)api
                 syncEngine:(BRSyncEngine *)syncEngine;
#endif

- (BRRebuildCommand *)rebuildCommand:(BRBuild *)build;
- (BRAbortCommand *)abortCommand:(BRBuild *)build;
#if TARGET_OS_OSX
- (BRDownloadLogsCommand *)logsCommand:(NSString *)buildSlug;
- (BROpenBuildCommand *)openCommand:(NSString *)buildSlug;
#endif
- (BRSyncCommand *)syncCommand;

@end

NS_ASSUME_NONNULL_END
