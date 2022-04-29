//
//  BRPersistentContainerBuilderTests.m
//  BitBotTests
//
//  Created by Deszip on 29.04.2022.
//  Copyright © 2022 Bitrise. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "Expecta/Expecta.h"

#import "BRPersistentContainerBuilder.h"

@interface BRPersistentContainerBuilderTests : XCTestCase

@end

@implementation BRPersistentContainerBuilderTests

- (void)setUp {
    
}

- (void)tearDown {
    
}

#pragma mark - Store building

- (void)testContainerHasProperSettings {
    id envMock = OCMClassMock([BREnvironment class]);
    BRPersistentContainerBuilder *builder = [[BRPersistentContainerBuilder alloc] initWithEnv:envMock];
    
    NSPersistentContainer *container = [builder buildContainer];
    expect(container.persistentStoreDescriptions.count).to.equal(1);
    
    NSPersistentStoreDescription *storeDescription = container.persistentStoreDescriptions.firstObject;
    expect(storeDescription.type).to.equal(NSSQLiteStoreType);
    expect(storeDescription.shouldInferMappingModelAutomatically).to.beTruthy();
    expect(storeDescription.shouldMigrateStoreAutomatically).to.beTruthy();
}

- (void)testContainerHasProperType {
    id envMock = OCMClassMock([BREnvironment class]);
    BRPersistentContainerBuilder *builder = [[BRPersistentContainerBuilder alloc] initWithEnv:envMock];
    
    NSPersistentContainer *container = [builder buildContainerOfType:NSInMemoryStoreType];
    NSPersistentStoreDescription *storeDescription = container.persistentStoreDescriptions.firstObject;
    expect(storeDescription.type).to.equal(NSInMemoryStoreType);
}

- (void)testContainerLocation {
    id envMock = OCMClassMock([BREnvironment class]);
    BRPersistentContainerBuilder *builder = [[BRPersistentContainerBuilder alloc] initWithEnv:envMock];
    
    NSURL *containerURL = [NSURL fileURLWithPath:NSTemporaryDirectory()];
    NSPersistentContainer *container = [builder buildContainerOfType:NSInMemoryStoreType atURL:containerURL];
    NSPersistentStoreDescription *storeDescription = container.persistentStoreDescriptions.firstObject;
    expect(storeDescription.URL).to.equal(containerURL);
}

#pragma mark - Store migration

- (void)testBaseMigrationFlow {
    /**
     - Build container
     - Add entry
     - Call migration
     - Build another container
     - Check entry
     */
    
    //...
}

@end
