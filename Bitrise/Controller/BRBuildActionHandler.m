//
//  BRBuildActionHandler.m
//  Bitrise
//
//  Created by Deszip on 05/08/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BRBuildActionHandler.h"

#import "BRRebuildCommand.h"
#import "BRAbortCommand.h"
#import "BRDownloadLogsCommand.h"
#import "BROpenBuildCommand.h"

@interface BRBuildActionHandler ()

@property (strong, nonatomic) BRBitriseAPI *api;
@property (strong, nonatomic) BRStorage *storage;

@end

@implementation BRBuildActionHandler

- (instancetype)initWithApi:(BRBitriseAPI *)api storage:(BRStorage *)storage {
    if (self = [super init]) {
        _api = api;
        _storage = storage;
    }
    
    return self;
}

- (void)rebuild:(NSString *)buildSlug {
    
}

- (void)abort:(NSString *)buildSlug {
    
}

- (void)downloadLog:(NSString *)buildSlug {
    
}

- (void)openBuild:(NSString *)buildSlug {
    
}

@end
