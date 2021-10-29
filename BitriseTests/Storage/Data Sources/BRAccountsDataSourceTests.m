//
//  BRAccountsDataSourceTests.m
//  BitBotTests
//
//  Created by Deszip on 29.10.2021.
//  Copyright © 2021 Bitrise. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "Expecta/Expecta.h"

#import <CoreData/CoreData.h>
#import "BRContainerBuilder.h"
#import "BRMockBuilder.h"

#import "BRAccountsDataSource.h"

@interface BRAccountsDataSourceTests : XCTestCase

@property (strong, nonatomic) BRMockBuilder *mockBuilder;
@property (strong, nonatomic) NSPersistentContainer *containerMock;

@property (strong, nonatomic) BRAccountsDataSource* dataSource;

@end

@implementation BRAccountsDataSourceTests

- (void)setUp {
    [super setUp];
    
    self.containerMock = [[BRContainerBuilder new] buildContainerOfType:NSInMemoryStoreType];
    self.dataSource = [[BRAccountsDataSource alloc] initWithContainer:self.containerMock];
    
    self.mockBuilder = [[BRMockBuilder alloc] initWithContext:self.containerMock.viewContext];
}

- (void)tearDown {

    self.containerMock = nil;
    self.dataSource = nil;
    self.mockBuilder = nil;
    
    [super tearDown];
}



@end
