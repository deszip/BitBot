//
//  BRDependencyContainer.m
//  Bitrise
//
//  Created by Deszip on 06/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BRDependencyContainer.h"

#import "BRContainerBuilder.h"

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

- (BRAppsDataSource *)appsDataSourceFor:(NSOutlineView *)outlineView {
    return [[BRAppsDataSource alloc] initWithContainer:self.persistenceContainer outline:outlineView];
}

- (BRAccountsDataSource *)accountsDataSourceFor:(NSOutlineView *)outlineView {
    return [[BRAccountsDataSource alloc] initWithContainer:self.persistenceContainer outline:outlineView];
}

@end
