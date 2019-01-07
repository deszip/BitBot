//
//  BRStorageTests.m
//  BitriseTests
//
//  Created by Deszip on 07/01/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "Expecta/Expecta.h"

#import <CoreData/CoreData.h>
#import <EasyMapping/EasyMapping.h>

#import "BRContainerBuilder.h"
#import "BRStorage.h"

static NSString * const kAccountSlug = @"account_slug";
static NSString * const kAccountToken = @"account_token";
static NSString * const kAccountTokenInvalid = @"account_token_invalid";

@interface BRStorageTests : XCTestCase

@property (strong, nonatomic) NSPersistentContainer *container;
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) BRStorage *storage;

@end

@implementation BRStorageTests

- (void)setUp {
    [super setUp];

    self.container = [[BRContainerBuilder new] buildContainerOfType:NSInMemoryStoreType];
    self.context = [self.container newBackgroundContext];
    self.storage = [[BRStorage alloc] initWithContext:self.context];
}

- (void)tearDown {
    self.container = nil;
    self.context = nil;
    self.storage = nil;
    
    [super tearDown];
}

#pragma mark - Accounts -

- (void)testStorageFetchesEmptyAccountsList {
    [self executeOnStorage:^{
        NSError *error;
        NSArray <BRAccount *> *accounts = [self.storage accounts:&error];
        expect(accounts.count).to.equal(0);
    }];
}

- (void)testStorageFetchesAccounts {
    [self buildAccountWithToken:kAccountToken slug:kAccountSlug];
    
    [self executeOnStorage:^{
        NSError *error;
        NSArray <BRAccount *> *accounts = [self.storage accounts:&error];
        
        expect(accounts.count).to.equal(1);
        expect(accounts[0].token).to.equal(kAccountToken);
    }];
}

- (void)testStorageSavesAccount {
    [self executeOnStorage:^{
        NSError *error;
        [self.storage saveAccount:[self accountInfo] error:&error];
        expect(error).to.beNil();
        
        NSArray <BRAccount *> *accounts = [self.storage accounts:&error];
        expect(accounts.count).to.equal(1);
        expect(accounts[0].token).to.equal(kAccountToken);
    }];
}

- (void)testStorageRemovesAccount {
    [self buildAccountWithToken:kAccountToken slug:kAccountSlug];
    
    [self executeOnStorage:^{
        NSError *error;
        BOOL result = [self.storage removeAccount:kAccountSlug error:&error];
        expect(error).to.beNil();
        expect(result).to.beTruthy();
        
        NSArray <BRAccount *> *accounts = [self.storage accounts:&error];
        expect(error).to.beNil();
        expect(accounts.count).to.equal(0);
    }];
}

- (void)testStorageHandlesIvalidAccountRemoval {
    [self executeOnStorage:^{
        NSError *error;
        BOOL result = [self.storage removeAccount:kAccountSlug error:&error];
        expect(error).to.beNil();
        expect(result).to.beFalsy();
    }];
}

#pragma mark - Apps -

- (void)testStorageAddsApps {
    
}

- (void)testStorageRemovesOutdatedApps {
    
}

- (void)testStorageIgnoresDuplicateAccounts {
    
}

- (void)testStorageFetchesApps {
    
}

- (void)testStorageFetchesEmptyAppsList {
    
}

- (void)testStorageAddsBuildToken {
    
}

- (void)testStorageIgnoresNilBuildToken {
    
}

#pragma mark - Builds -

//...

#pragma mark - Builders -

- (void)buildAccountWithToken:(NSString *)token slug:(NSString *)slug {
    BRAccount *account = [NSEntityDescription insertNewObjectForEntityForName:@"BRAccount" inManagedObjectContext:self.context];
    account.token = token;
    account.slug = slug;
    
    [self.context save:nil];
}

- (BRAccountInfo *)accountInfo {
    return [[BRAccountInfo alloc] initWithResponse:@{} token:kAccountToken];
}

#pragma mark - Tools -

- (void)executeOnStorage:(void (^)(void))action {
    XCTestExpectation *e = [self expectationWithDescription:@""];
    
    [self.storage perform:^{
        action();
        [e fulfill];
    }];
    
    [self waitForExpectations:@[e] timeout:0.1];
}

@end
