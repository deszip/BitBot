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

static NSString * const kAppSlug1 = @"app_slug_1";
static NSString * const kAppSlug2 = @"app_slug_2";
static NSString * const kAppSlugInvalid = @"app_slug_invalid";
static NSString * const kAppBuildToken = @"app_build_token";

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
    [self buildAccountWithToken:kAccountToken slug:kAccountSlug];
    
    [self executeOnStorage:^{
        NSArray <BRAccount *> *accounts = [self.storage accounts:nil];
        NSError *error;
        [self.storage updateApps:@[[self appInfoWithSlug:kAppSlug1]] forAccount:accounts[0] error:&error];
        
        NSArray <BRApp *> *apps = [self.storage appsForAccount:accounts[0] error:&error];
        expect(apps.count).to.equal(1);
    }];
}

- (void)testStorageRemovesOutdatedApps {
    [self buildAccountWithToken:kAccountToken slug:kAccountSlug];
    
    [self executeOnStorage:^{
        // Insert app 1
        NSArray <BRAccount *> *accounts = [self.storage accounts:nil];
        NSError *error;
        [self.storage updateApps:@[[self appInfoWithSlug:kAppSlug1]] forAccount:accounts[0] error:&error];
        
        // Update with app 2
        [self.storage updateApps:@[[self appInfoWithSlug:kAppSlug2]] forAccount:accounts[0] error:&error];
        
        // Verify only app 2 left in storage
        NSArray <BRApp *> *apps = [self.storage appsForAccount:accounts[0] error:&error];
        expect(apps.count).to.equal(1);
        expect(apps[0].slug).to.equal(kAppSlug2);
    }];
}

- (void)testStorageIgnoresDuplicateAccounts {
    [self buildAccountWithToken:kAccountToken slug:kAccountSlug];
    [self buildAccountWithToken:kAccountToken slug:kAccountSlug];
    
    [self executeOnStorage:^{
        NSArray <BRAccount *> *accounts = [self.storage accounts:nil];
        NSError *error;
        BOOL result = [self.storage updateApps:@[[self appInfoWithSlug:kAppSlug1]] forAccount:accounts[0] error:&error];
        
        expect(result).to.beFalsy();
    }];
}

- (void)testStorageFetchesApps {
    [self executeOnStorage:^{
        BRAccount *account = [self buildAccountWithToken:kAccountToken slug:kAccountSlug];
        [self buildAppWithSlug:kAppSlug1 forAccount:account];
        
        NSError *error;
        NSArray <BRApp *> *apps = [self.storage appsForAccount:account error:&error];
        expect(apps.count).to.equal(1);
        expect(apps[0].slug).to.equal(kAppSlug1);
    }];
}

- (void)testStorageFetchesEmptyAppsList {
    [self executeOnStorage:^{
        BRAccount *account = [self buildAccountWithToken:kAccountToken slug:kAccountSlug];
        
        NSError *error;
        NSArray <BRApp *> *apps = [self.storage appsForAccount:account error:&error];
        expect(apps.count).to.equal(0);
    }];
}

- (void)testStorageAddsBuildToken {
    [self executeOnStorage:^{
        BRAccount *account = [self buildAccountWithToken:kAccountToken slug:kAccountSlug];
        [self buildAppWithSlug:kAppSlug1 forAccount:account];
        
        NSError *error;
        BOOL result = [self.storage addBuildToken:kAppBuildToken toApp:kAppSlug1 error:&error];
        NSArray <BRApp *> *apps = [self.storage appsForAccount:account error:&error];
        expect(result).to.beTruthy();
        expect(apps[0].buildToken).to.equal(kAppBuildToken);
    }];
}

- (void)testStorageIgnoresNilBuildToken {
    [self executeOnStorage:^{
        BRAccount *account = [self buildAccountWithToken:kAccountToken slug:kAccountSlug];
        [self buildAppWithSlug:kAppSlug1 forAccount:account];
        
        NSError *error;
        BOOL result = [self.storage addBuildToken:nil toApp:kAppSlug1 error:&error];
        NSArray <BRApp *> *apps = [self.storage appsForAccount:account error:&error];
        expect(result).to.beFalsy();
        expect(apps[0].buildToken).to.beNil();
    }];
}

#pragma mark - Builds -

//...

#pragma mark - Builders -

- (BRAccount *)buildAccountWithToken:(NSString *)token slug:(NSString *)slug {
    BRAccount *account = [NSEntityDescription insertNewObjectForEntityForName:@"BRAccount" inManagedObjectContext:self.context];
    account.token = token;
    account.slug = slug;
    
    [self.context save:nil];
    
    return account;
}

- (BRApp *)buildAppWithSlug:(NSString *)slug forAccount:(BRAccount *)account {
    BRApp *app = [NSEntityDescription insertNewObjectForEntityForName:@"BRApp" inManagedObjectContext:self.context];
    app.slug = slug;
    app.account = account;
    
    [self.context save:nil];
    
    return app;
}

- (BRAccountInfo *)accountInfo {
    return [[BRAccountInfo alloc] initWithResponse:@{ @"slug" : kAccountSlug } token:kAccountToken];
}

- (BRAppInfo *)appInfoWithSlug:(NSString *)slug {
    return [[BRAppInfo alloc] initWithResponse:@{ @"slug" : slug }];
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
