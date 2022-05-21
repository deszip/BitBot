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
    BREnvironment *env = [[BREnvironment alloc] initWithAutorun:[BRAutorun new]];
    [self dropStoreAtURL:[env storeURLForMacOSApp]];
    [self dropStoreAtURL:[env storeURLForAppGroup]];
    
    [super tearDown];
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

- (void)testStoreCreationAtSupportDirectory {
    BREnvironment *env = [[BREnvironment alloc] initWithAutorun:[BRAutorun new]];
    [self dropStoreAtURL:[env storeURLForMacOSApp]];
    
    // Build app directory container
    id envMock = OCMPartialMock(env);
    OCMStub([envMock appVersion]).andReturn(BRAppVersion_1_2_0);
    BRPersistentContainerBuilder *builder = [[BRPersistentContainerBuilder alloc] initWithEnv:envMock];
    NSPersistentContainer *container = [builder buildContainer];
    
    // Verify store location
    NSPersistentStore *store = container.persistentStoreCoordinator.persistentStores.firstObject;
    expect(store.URL).to.equal([env storeURLForMacOSApp]);
}

- (void)testStoreCreationAtAppGroup {
    BREnvironment *env = [[BREnvironment alloc] initWithAutorun:[BRAutorun new]];
    [self dropStoreAtURL:[env storeURLForAppGroup]];
    
    // Build app directory container
    id envMock = OCMPartialMock(env);
    OCMStub([envMock appVersion]).andReturn(BRAppVersion_2_0_0);
    BRPersistentContainerBuilder *builder = [[BRPersistentContainerBuilder alloc] initWithEnv:envMock];
    NSPersistentContainer *container = [builder buildContainer];
    
    // Verify store location
    NSPersistentStore *store = container.persistentStoreCoordinator.persistentStores.firstObject;
    expect(store.URL).to.equal([env storeURLForAppGroup]);
}

- (void)testBaseMigrationFlow {
    BREnvironment *env = [[BREnvironment alloc] initWithAutorun:[BRAutorun new]];
    [self dropStoreAtURL:[env storeURLForMacOSApp]];
    [self dropStoreAtURL:[env storeURLForAppGroup]];
    
    // Build app directory container
    id autorunMock_1 = OCMClassMock([BRAutorun class]);
    BREnvironment *env_1 = [[BREnvironment alloc] initWithAutorun:autorunMock_1];
    id envMock_1 = OCMPartialMock(env_1);
    OCMStub([envMock_1 appVersion]).andReturn(BRAppVersion_1_2_0);
    BRPersistentContainerBuilder *builder_1 = [[BRPersistentContainerBuilder alloc] initWithEnv:envMock_1];
    NSPersistentContainer *container_1 = [builder_1 buildContainer];
    
    // Get mock builder for container in support directory and add test entry
    self.mockBuilder = [[BRMockBuilder alloc] initWithContext:container_1.viewContext];
    BRBuild *sourceBuild = [self.mockBuilder buildWithSlug:kBuildSlug1 status:@(0) app:nil];
    
    // Build app group container
    id autorunMock_2 = OCMClassMock([BRAutorun class]);
    BREnvironment *env_2 = [[BREnvironment alloc] initWithAutorun:autorunMock_2];
    id envMock_2 = OCMPartialMock(env_2);
    OCMStub([envMock_2 appVersion]).andReturn(BRAppVersion_2_0_0);
    
    // This will trigger store migration because app version stubbed to 2.0.0
    BRPersistentContainerBuilder *builder_2 = [[BRPersistentContainerBuilder alloc] initWithEnv:envMock_2];
    NSPersistentContainer *container_2 = [builder_2 buildContainer];
    
    // Rebuild mock builder for app group based container and try fetching the build
    self.mockBuilder = [[BRMockBuilder alloc] initWithContext:container_2.viewContext];
    BRBuild *migratedBuild = [self.mockBuilder buildWithSlug:kBuildSlug1];
    
    // Verify builds
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

- (void)dropStoreAtURL:(NSURL *)storeURL {
    if ([[NSFileManager defaultManager] fileExistsAtPath:storeURL.path]) {
        NSURL *shmURL = [NSURL fileURLWithPath:[[storeURL path] stringByAppendingString:@"-shm"]];
        NSURL *walURL = [NSURL fileURLWithPath:[[storeURL path] stringByAppendingString:@"-wal"]];

        NSError *error;
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];
        [[NSFileManager defaultManager] removeItemAtURL:shmURL error:&error];
        [[NSFileManager defaultManager] removeItemAtURL:walURL error:&error];
    }
}

@end
