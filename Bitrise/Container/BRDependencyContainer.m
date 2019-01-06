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

- (BRAppsDataSource *)appsDataSource {
    return [[BRAppsDataSource alloc] initWithContainer:self.persistenceContainer cellBuilder:[self cellBuilder]];
}

- (BRAccountsDataSource *)accountsDataSource {
    return [[BRAccountsDataSource alloc] initWithContainer:self.persistenceContainer];
}

#pragma mark - BRInteractionProvider -

- (BRSyncEngine *)syncEngine {
    return [[BRSyncEngine alloc] initWithAPI:self.bitriseAPI storage:self.storage];
}

- (BRBitriseAPI *)bitriseAPI {
    return [BRBitriseAPI new];
}

- (BRStorage *)storage {
    return [[BRStorage alloc] initWithContainer:self.persistenceContainer];
}

- (BRObserver *)commandObserver {
    return [BRObserver new];
}

#pragma mark - BREnvironmentProvider -

- (BREnvironment *)appEnvironment {
    return [[BREnvironment alloc] initWithAutorun:[BRAutorun new]];
}

@end
