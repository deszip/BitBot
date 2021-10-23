//
//  BRAccountsObserverTests.m
//  BitBotTests
//
//  Created by Deszip on 17.10.2021.
//  Copyright © 2021 Bitrise. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "Expecta/Expecta.h"

#import <CoreData/CoreData.h>
#import <EasyMapping/EasyMapping.h>
#import "BRMockBuilder.h"

#import "BRContainerBuilder.h"
#import "BRAccountsObserver.h"

@interface BRAccountsObserverTests : XCTestCase

@property (strong, nonatomic) NSPersistentContainer *container;
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) BRMockBuilder *mockBuilder;

@property (strong, nonatomic) BRAccountsObserver *observer;

@end

@implementation BRAccountsObserverTests

- (void)setUp {
    [super setUp];
    
    self.container = [[BRContainerBuilder new] buildContainerOfType:NSInMemoryStoreType];
    self.context = [self.container newBackgroundContext];
    self.mockBuilder = [[BRMockBuilder alloc] initWithContext:self.context];
    
    self.observer = [[BRAccountsObserver alloc] initWithContext:self.context];
}

- (void)tearDown {
    self.container = nil;
    self.context = nil;
    self.mockBuilder = nil;
    
    self.observer = nil;
    
    [super tearDown];
}

- (void)testInitialStateIsEmpty {
    expect(self.observer.state).to.equal(BRAccountsStateEmpty);
}

- (void)testObserverDoesNotTriggerCallbackOnStart {
    XCTestExpectation *e = [self expectationWithDescription:@""];
    e.inverted = YES;
    
    [self.observer start:^(BRAccountsState state) { [e fulfill]; }];
    
    [self waitForExpectations:@[e] timeout:0.1];
}

- (void)testObserverChangeStateIfAccountsPresent {
    XCTestExpectation *e = [self expectationWithDescription:@""];
    [self.mockBuilder buildAccountWithToken:kAccountToken slug:kAccountSlug];
    
    [self.observer start:^(BRAccountsState state) {
        expect(state).to.equal(BRAccountsStateHasData);
        expect(self.observer.state).to.equal(BRAccountsStateHasData);
        [e fulfill];
    }];
    
    [self waitForExpectations:@[e] timeout:0.1];
}

- (void)testObserverHandlesContextChangeAfetrStart {
    XCTestExpectation *e = [self expectationWithDescription:@""];
    
    [self.observer start:^(BRAccountsState state) {
        expect(state).to.equal(BRAccountsStateHasData);
        expect(self.observer.state).to.equal(BRAccountsStateHasData);
        [e fulfill];
    }];
    [self.mockBuilder buildAccountWithToken:kAccountToken slug:kAccountSlug];
    
    expect(self.observer.state).to.equal(BRAccountsStateHasData);
    
    [self waitForExpectations:@[e] timeout:0.1];
}

- (void)testObserverOverwritesCallback {
    XCTestExpectation *e1 = [self expectationWithDescription:@""];
    e1.inverted = YES;
    XCTestExpectation *e2 = [self expectationWithDescription:@""];
    
    [self.observer start:^(BRAccountsState state) {
        [e1 fulfill];
    }];
    [self.observer start:^(BRAccountsState state) {
        [e2 fulfill];
    }];
    
    [self.mockBuilder buildAccountWithToken:kAccountToken slug:kAccountSlug];
    
    [self waitForExpectations:@[e1, e2] timeout:0.1];
}

@end
