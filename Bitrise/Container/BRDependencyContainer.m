//
//  BRDependencyContainer.m
//  Bitrise
//
//  Created by Deszip on 06/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BRDependencyContainer.h"

#import "BRContainerBuilder.h"
#import "BRCellBuilder.h"

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

- (BRBitriseAPI *)bitriseAPI {
    return [BRBitriseAPI new];
}

- (BRStorage *)storage {
    return [[BRStorage alloc] initWithContainer:self.persistenceContainer];
}

@end
