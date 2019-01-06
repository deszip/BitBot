//
//  BRDependencyContainer.h
//  BitBot
//
//  Created by Deszip on 06/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BRAppsDataSource.h"
#import "BRAccountsDataSource.h"

#import "BRSyncEngine.h"
#import "BRBitriseAPI.h"
#import "BRStorage.h"
#import "BRObserver.h"
#import "BREnvironment.h"

@protocol BRDataSourceProvider <NSObject>

- (BRAppsDataSource *)appsDataSource;
- (BRAccountsDataSource *)accountsDataSource;

@end

@protocol BRInteractionProvider <NSObject>

- (BRSyncEngine *)syncEngine;
- (BRBitriseAPI *)bitriseAPI;
- (BRStorage *)storage;
- (BRObserver *)commandObserver;

@end

@protocol BREnvironmentProvider <NSObject>

- (BREnvironment *)environment;

@end


@interface BRDependencyContainer : NSObject <BRDataSourceProvider, BRInteractionProvider, BREnvironmentProvider>

@end
