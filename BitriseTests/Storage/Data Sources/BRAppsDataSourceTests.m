//
//  BRAppsDataSourceTests.m
//  BitBotTests
//
//  Created by Deszip on 21.04.2021.
//  Copyright © 2021 Bitrise. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "Expecta/Expecta.h"

#import <CoreData/CoreData.h>
#import "BRPersistentContainerBuilder.h"
#import "BRMockBuilder.h"

#import "BRAppsDataSource.h"

@interface BRAppsDataSourceTests : XCTestCase

@property (strong, nonatomic) BRMockBuilder *mockBuilder;

@property (strong, nonatomic) NSPersistentContainer *containerMock;
@property (strong, nonatomic) BRCellBuilder *cellBuilderMock;

@property (strong, nonatomic) BRAppsDataSource* dataSource;

@end

@implementation BRAppsDataSourceTests

- (void)setUp {
    [super setUp];
    
    BRPersistentContainerBuilder *containerBuilder = [[BRPersistentContainerBuilder alloc] initWithEnv:OCMClassMock([BREnvironment class])];
    self.containerMock = [containerBuilder buildContainerOfType:NSInMemoryStoreType];
    self.cellBuilderMock = OCMClassMock([BRCellBuilder class]);
    
    self.dataSource = [[BRAppsDataSource alloc] initWithContainer:self.containerMock cellBuilder:self.cellBuilderMock];
    
    self.mockBuilder = [[BRMockBuilder alloc] initWithContext:self.containerMock.viewContext];
}

- (void)tearDown {
    
    self.containerMock = nil;
    self.cellBuilderMock = nil;
    self.dataSource = nil;
    self.mockBuilder = nil;
    
    [super tearDown];
}

- (void)testDataSourceBindsOutline {
    id outlineMock = OCMClassMock([NSOutlineView class]);
    
    OCMExpect([outlineMock setDataSource:self.dataSource]);
    OCMExpect([outlineMock setDelegate:self.dataSource]);
    OCMExpect([outlineMock reloadData]);
    
    [self.dataSource bind:outlineMock];
    
    OCMVerifyAll(outlineMock);
}

- (void)testdataSourceReloadsViewOnFetch {
    id outlineMock = OCMClassMock([NSOutlineView class]);
    [self.dataSource bind:outlineMock];
    
    OCMExpect([outlineMock reloadData]);
    [self.dataSource fetch];
    
    OCMVerifyAll(outlineMock);
}

- (void)testDataSourceProvidesBuilds {
    BRBuild *build = [self.mockBuilder buildWithSlug:kBuildSlug1 status:@(0) app:nil];
    
    id outlineMock = OCMPartialMock([NSOutlineView new]);
    [self.dataSource bind:outlineMock];
    
    expect([(id <NSOutlineViewDataSource>)[outlineMock dataSource] outlineView:outlineMock child:0 ofItem:nil]).to.equal(build);
}

- (void)testOutlineIsFlat {
    BRBuild *build =  [self.mockBuilder buildWithSlug:kBuildSlug1 status:@(0) app:nil];
    
    id outlineMock = OCMPartialMock([NSOutlineView new]);
    [self.dataSource bind:outlineMock];
    
    expect([(id <NSOutlineViewDataSource>)[outlineMock dataSource] outlineView:outlineMock isItemExpandable:build]).to.beFalsy();
}

@end
