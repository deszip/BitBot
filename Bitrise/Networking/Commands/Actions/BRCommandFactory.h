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
#import "BREnvironment.h"

#import "BRRebuildCommand.h"
#import "BRAbortCommand.h"
#import "BRDownloadLogsCommand.h"
#import "BROpenBuildCommand.h"
#import "BRSyncCommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRCommandFactory : NSObject

- (instancetype)initWithAPI:(BRBitriseAPI *)api
                 syncEngine:(BRSyncEngine *)syncEngine
                environment:(BREnvironment *)environment;

- (BRRebuildCommand *)rebuildCommand:(BRBuild *)build;
- (BRAbortCommand *)abortCommand:(BRBuild *)build;
- (BRDownloadLogsCommand *)logsCommand:(NSString *)buildSlug;
- (BROpenBuildCommand *)openCommand:(NSString *)buildSlug;
- (BRSyncCommand *)syncCommand;

@end

NS_ASSUME_NONNULL_END
