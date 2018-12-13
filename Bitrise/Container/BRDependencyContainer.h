//
//  BRDependencyContainer.h
//  Bitrise
//
//  Created by Deszip on 06/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BRAppsDataSource.h"
#import "BRAccountsDataSource.h"

#import "BRSyncEngine.h"
#import "BRBitriseAPI.h"
#import "BRStorage.h"
#import "BRObserver.h"

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


@interface BRDependencyContainer : NSObject <BRDataSourceProvider, BRInteractionProvider>

@end
