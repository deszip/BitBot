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
#import "BRMockBuilder.h"

@interface BRPersistentContainerBuilderTests : XCTestCase

@property (strong, nonatomic) BRMockBuilder *mockBuilder;

@end

@implementation BRPersistentContainerBuilderTests

- (void)setUp {
    [super setUp];
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
    // Build app directory container
    id autorunMock_1 = OCMClassMock([BRAutorun class]);
    BREnvironment *env_1 = [[BREnvironment alloc] initWithAutorun:autorunMock_1];
    id envMock_1 = OCMPartialMock(env_1);
    OCMStub([envMock_1 appVersion]).andReturn(BRAppVersion_1_2_0);
    BRPersistentContainerBuilder *builder_1 = [[BRPersistentContainerBuilder alloc] initWithEnv:envMock_1];
    NSPersistentContainer *container_1 = [builder_1 buildContainer];
    
    // Build app group container
    id autorunMock_2 = OCMClassMock([BRAutorun class]);
    BREnvironment *env_2 = [[BREnvironment alloc] initWithAutorun:autorunMock_2];
    id envMock_2 = OCMPartialMock(env_2);
    OCMStub([envMock_2 appVersion]).andReturn(BRAppVersion_2_0_0);
    
    // This will trigger store migration because app version stubbed to 2.0.0
    BRPersistentContainerBuilder *builder_2 = [[BRPersistentContainerBuilder alloc] initWithEnv:envMock_2];
//    NSPersistentContainer *container_2 = [builder_2 buildContainer];
    
    self.mockBuilder = [[BRMockBuilder alloc] initWithContext:container_1.viewContext];
    
    // Add entry
    BRBuild *sourceBuild = [self.mockBuilder buildWithSlug:kBuildSlug1 status:@(0) app:nil];
    
    // Call migration
//    [builder migrateStoreToAppGroupContainer];
//    [builder_2 forceMigrateStoreToAppGroupContainer];
    
    // Build another container
    NSPersistentContainer *container_2 = [builder_2 buildContainer];
    self.mockBuilder = [[BRMockBuilder alloc] initWithContext:container_2.viewContext];
    
    // Check entry
    BRBuild *migratedBuild = [self.mockBuilder buildWithSlug:kBuildSlug1];
    
    expect(migratedBuild).toNot.beNil();
    expect(migratedBuild.slug).to.equal(sourceBuild.slug);
}

#pragma mark - Tools

- (NSURL *)storeURLAt:(NSSearchPathDirectory)containerRoot {
    NSURL *appsURL = [[NSFileManager defaultManager] URLsForDirectory:containerRoot inDomains:NSUserDomainMask][0];
    NSURL *appDirectoryURL = [appsURL URLByAppendingPathComponent:@"Bitrise"];

    BOOL isDir;
    if (![[NSFileManager defaultManager] fileExistsAtPath:appDirectoryURL.path isDirectory:&isDir]) {
        NSError *error;
        BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:appDirectoryURL.path withIntermediateDirectories:YES attributes:nil error:&error];
        if (!result) {
            return nil;
        }
    }

    return [appDirectoryURL URLByAppendingPathComponent:@"bitrise.sqlite"];
}

@end
