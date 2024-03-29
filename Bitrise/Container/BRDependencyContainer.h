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
#import "BRLogsDataSource.h"
#import "BRAccountsObserver.h"

#import "BRSyncEngine.h"
#import "BRBitriseAPI.h"
#import "BRStorage.h"
#import "BRObserver.h"
#import "BREnvironment.h"
#import "BRLogObserver.h"

#import "BRBuildMenuController.h"
#import "BRSettingsMenuController.h"
#import "BRFiltersMenuController.h"

@protocol BRDataSourceProvider <NSObject>

- (BRCellBuilder *)cellBuilder;
- (BRAppsDataSource *)appsDataSourceWithCellBuilder:(BRCellBuilder *)cellBuilder;
- (BRAccountsDataSource *)accountsDataSource;
- (BRLogsDataSource *)logDataSource;
- (BRAccountsObserver *)accountsObserver;

@end

@protocol BRInteractionProvider <NSObject>

- (BRSyncEngine *)syncEngine;
- (BRBitriseAPI *)bitriseAPI;
- (BRStorage *)storage;
- (BRObserver *)commandObserver;
- (BRLogObserver *)logObserver;

@end

@protocol BREnvironmentProvider <NSObject>

- (BREnvironment *)appEnvironment;

@end

@protocol BRMenuControllerProvider <NSObject>

- (BRBuildMenuController *)buildMenuController;
- (BRSettingsMenuController *)settingsMenuController;
- (BRFiltersMenuController *)filterMenuController;

@end

@interface BRDependencyContainer : NSObject <BRDataSourceProvider, BRInteractionProvider, BREnvironmentProvider, BRMenuControllerProvider>

@end
