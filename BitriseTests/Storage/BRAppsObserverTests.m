//
//  BRAppsObserverTests.m
//  BitBotTests
//
//  Created by Deszip on 04.08.2022.
//  Copyright © 2022 Bitrise. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "Expecta/Expecta.h"

#import <CoreData/CoreData.h>
#import <EasyMapping/EasyMapping.h>
#import "BRMockBuilder.h"

#import "BRPersistentContainerBuilder.h"
#import "BRAppsObserver.h"

@interface BRAppsObserverTests : XCTestCase

@property (strong, nonatomic) NSPersistentContainer *container;
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) BRMockBuilder *mockBuilder;

@property (strong, nonatomic) BRAppsObserver *observer;

@end

@implementation BRAppsObserverTests

- (void)setUp {
    [super setUp];
    
    BRPersistentContainerBuilder *containerBuilder = [[BRPersistentContainerBuilder alloc] initWithEnv:OCMClassMock([BREnvironment class])];
    self.container = [containerBuilder buildContainerOfType:NSInMemoryStoreType];
    self.context = [self.container newBackgroundContext];
    self.mockBuilder = [[BRMockBuilder alloc] initWithContext:self.context];
    
    self.observer = [[BRAppsObserver alloc] initWithContext:self.context];
}

- (void)tearDown {
    self.container = nil;
    self.context = nil;
    self.mockBuilder = nil;
    
    self.observer = nil;
    
    [super tearDown];
}

- (void)testObserverTriggersCallbackOnAppCreation {
    XCTestExpectation *e = [self expectationWithDescription:@""];
    
    [self.observer startAppObserving:kAppSlug1 callback:^(BRApp *app) {
        [e fulfill];
    }];
    
    BTRAccount *acc = [self.mockBuilder buildAccountWithToken:kAccountToken slug:kAccountSlug];
    [self.mockBuilder buildAppWithSlug:kAppSlug1 forAccount:acc];
    
    [self waitForExpectations:@[e] timeout:0.1];
}

- (void)testObserverTriggersCallbackOnStartObserving {
    XCTestExpectation *e = [self expectationWithDescription:@""];
    
    BTRAccount *acc = [self.mockBuilder buildAccountWithToken:kAccountToken slug:kAccountSlug];
    [self.mockBuilder buildAppWithSlug:kAppSlug1 forAccount:acc];
    
    [self.observer startAppObserving:kAppSlug1 callback:^(BRApp *app) {
        [e fulfill];
    }];
    
    [self waitForExpectations:@[e] timeout:0.1];
}

- (void)testObserverTriggersCallbackForCorrectApp {
    XCTestExpectation *e = [self expectationWithDescription:@""];
    
    BTRAccount *acc = [self.mockBuilder buildAccountWithToken:kAccountToken slug:kAccountSlug];
    [self.mockBuilder buildAppWithSlug:kAppSlug1 forAccount:acc];
    [self.mockBuilder buildAppWithSlug:kAppSlug2 forAccount:acc];
    
    [self.observer startAppObserving:kAppSlug1 callback:^(BRApp *app) {
        expect(app.slug).to.equal(kAppSlug1);
        [e fulfill];
    }];
    
    [self waitForExpectations:@[e] timeout:0.1];
}

- (void)testObserverTriggersCallbackForForAppUpdate {
    XCTestExpectation *e = [self expectationWithDescription:@""];
    e.expectedFulfillmentCount = 2;
    
    BTRAccount *acc = [self.mockBuilder buildAccountWithToken:kAccountToken slug:kAccountSlug];
    BRApp *app = [self.mockBuilder buildAppWithSlug:kAppSlug1 forAccount:acc];
    
    [self.observer startAppObserving:kAppSlug1 callback:^(BRApp *app) {
        expect(app.slug).to.equal(kAppSlug1);
        [e fulfill];
    }];
    
    [self.mockBuilder updateApp:app];
    
    [self waitForExpectations:@[e] timeout:0.1];
}

@end
