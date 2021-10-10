//
//  BRDependencyContainer.m
//  BitBot
//
//  Created by Deszip on 06/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRDependencyContainer.h"

#import "BRContainerBuilder.h"
#import "BRCellBuilder.h"
#import "BRAutorun.h"
#import "BRCommandFactory.h"

@interface BRDependencyContainer ()

@property (strong, nonatomic) NSPersistentContainer *persistenceContainer;

@end

@implementation BRDependencyContainer

- (instancetype)init {
    if (self = [super init]) {
        BRContainerBuilder *containerBuilder = [BRContainerBuilder new];
        _persistenceContainer = [containerBuilder buildContainer];
    }
    
    return self;
}

- (BRCellBuilder *)cellBuilder {
    return [BRCellBuilder new];
}

#pragma mark - BRDataSourceProvider -

- (BRAppsDataSource *)appsDataSourceWithCellBuilder:(BRCellBuilder *)cellBuilder {
    return [[BRAppsDataSource alloc] initWithContainer:self.persistenceContainer cellBuilder:cellBuilder];
}

- (BRAccountsDataSource *)accountsDataSource {
    return [[BRAccountsDataSource alloc] initWithContainer:self.persistenceContainer];
}

- (BRLogsDataSource *)logDataSource {
    BRLogPresenter *logPresenter = [[BRLogPresenter alloc] initWithANSIHelper:[AMR_ANSIEscapeHelper new]];
    return [[BRLogsDataSource alloc] initWithContainer:self.persistenceContainer logPresenter:logPresenter];
}

- (BRAccountsObserver *)accountsObserver {
    return [[BRAccountsObserver alloc] initWithContainer:self.persistenceContainer];
}

#pragma mark - BRInteractionProvider -

- (BRSyncEngine *)syncEngine {
    return [[BRSyncEngine alloc] initWithAPI:self.bitriseAPI storage:self.storage];
}

- (BRBitriseAPI *)bitriseAPI {
    return [BRBitriseAPI new];
}

- (BRStorage *)storage {
    return [[BRStorage alloc] initWithContext:[self.persistenceContainer newBackgroundContext]];
}

- (BRObserver *)commandObserver {
    return [BRObserver new];
}

- (BRLogObserver *)logObserver {
    return [[BRLogObserver alloc] initWithAPI:self.bitriseAPI storage:self.storage];
}

#pragma mark - BREnvironmentProvider -

- (BREnvironment *)appEnvironment {
    BRNotificationDispatcher *nDispatcher = [[BRNotificationDispatcher alloc] initWithDefaults:[NSUserDefaults standardUserDefaults]
                                                                                            nc:[NSUserNotificationCenter defaultUserNotificationCenter]];
    return [[BREnvironment alloc] initWithAutorun:[BRAutorun new] notificationsDispatcher:nDispatcher];
}

- (NSNotificationCenter *)notificationCenter {
    return [NSNotificationCenter defaultCenter];
}

@end
