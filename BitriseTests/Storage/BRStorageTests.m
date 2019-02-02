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

static NSString * const kBuildSlug1 = @"build_slug_1";
static NSString * const kBuildSlug2 = @"build_slug_2";
static NSString * const kBuildSlug3 = @"build_slug_3";
static NSString * const kBuildSlug4 = @"build_slug_4";

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

- (void)testStorageIgnoresAppDuplicate {
    [self executeOnStorage:^{
        BRAccount *account = [self buildAccountWithToken:kAccountToken slug:kAccountSlug];
        [self buildAppWithSlug:kAppSlug1 forAccount:account];
        [self buildAppWithSlug:kAppSlug1 forAccount:account];
        
        NSError *error;
        BOOL result = [self.storage addBuildToken:kAppBuildToken toApp:kAppSlug1 error:&error];
        NSArray <BRApp *> *apps = [self.storage appsForAccount:account error:&error];
        expect(result).to.beFalsy();
        expect(apps[0].buildToken).to.beNil();
    }];
}

#pragma mark - Builds -

- (void)testStorageFetchesBuildWithSlug {
    [self executeOnStorage:^{
        [self buildWithSlug:kBuildSlug1 staus:@(0) app:nil];
        [self buildWithSlug:kBuildSlug2 staus:@(1) app:nil];
        NSError *error;
        BRBuild *build = [self.storage buildWithSlug:kBuildSlug1 error:&error];

        expect(build.slug).to.equal(kBuildSlug1);
        expect(error).to.beNil();
    }];
}

- (void)testStorageReturnsNilIfNoBuildFound {
    [self executeOnStorage:^{
        [self buildWithSlug:kBuildSlug1 staus:@(0) app:nil];
        NSError *error;
        BRBuild *build = [self.storage buildWithSlug:kBuildSlug2 error:&error];
        
        expect(build).to.beNil();
        expect(error).to.beNil();
    }];
}

- (void)testStorageReturnsNilIfDuplicateFound {
    [self executeOnStorage:^{
        [self buildWithSlug:kBuildSlug1 staus:@(0) app:nil];
        [self buildWithSlug:kBuildSlug1 staus:@(0) app:nil];
        NSError *error;
        BRBuild *build = [self.storage buildWithSlug:kBuildSlug1 error:&error];
        
        expect(build).to.beNil();
        expect(error).to.beNil();
    }];
}

- (void)testStorageFetchesRunningBuilds {
    [self executeOnStorage:^{
        [self buildWithSlug:kBuildSlug1 staus:@(0) app:nil];
        [self buildWithSlug:kBuildSlug2 staus:@(1) app:nil];
        NSError *error;
        NSArray <BRBuild *> *builds = [self.storage runningBuilds:&error];
        
        expect(builds.count).to.equal(1);
        expect(error).to.beNil();
        expect(builds[0].status.integerValue).to.equal(0);
    }];
}

- (void)testStorageSortsRunningBuilds {
    [self executeOnStorage:^{
        [self buildWithSlug:kBuildSlug1 staus:@(0) app:nil];
        [self buildWithSlug:kBuildSlug2 staus:@(0) app:nil];
        NSError *error;
        NSArray <BRBuild *> *builds = [self.storage runningBuilds:&error];
        
        expect(builds.count).to.equal(2);
        
        // Verify build at index 0 is the latest started
        BOOL ordered = [[builds[0].triggerTime earlierDate:builds[1].triggerTime] isEqualToDate:builds[1].triggerTime];
        expect(ordered).to.beTruthy();
    }];
}

- (void)testStorageReturnsNilIfNoRunningBuilds {
    [self executeOnStorage:^{
        NSError *error;
        NSArray <BRBuild *> *builds = [self.storage runningBuilds:&error];
        
        expect(builds.count).to.equal(0);
        expect(error).to.beNil();
    }];
}

- (void)testLatestBuildFetchIgnoresRunningBuilds {
    [self executeOnStorage:^{
        BRAccount *acc = [self buildAccountWithToken:kAccountToken slug:kAccountSlug];
        BRApp *app = [self buildAppWithSlug:kAppSlug1 forAccount:acc];
        BRBuild *finishedBuild = [self buildWithSlug:kBuildSlug1 staus:@(1) app:app];
        [self buildWithSlug:kBuildSlug1 staus:@(0) app:app];
        
        NSError *error;
        BRBuild *latestBuild = [self.storage latestBuild:app error:&error];
        
        expect(latestBuild.slug).to.equal(finishedBuild.slug);
        expect(error).to.beNil();
    }];
}

- (void)testLatestBuildFetchOldestRunningBuild {
    [self executeOnStorage:^{
        // Add four builds, only first and last are finished
        BRAccount *acc = [self buildAccountWithToken:kAccountToken slug:kAccountSlug];
        BRApp *app = [self buildAppWithSlug:kAppSlug1 forAccount:acc];
        [self buildWithSlug:kBuildSlug1 staus:@(1) app:app];
        BRBuild *targetBuild = [self buildWithSlug:kBuildSlug2 staus:@(0) app:app];
        [self buildWithSlug:kBuildSlug3 staus:@(0) app:app];
        [self buildWithSlug:kBuildSlug4 staus:@(1) app:app];
        
        // Fetch latest build
        NSError *error;
        BRBuild *latestBuild = [self.storage latestBuild:app error:&error];
        
        // Verify latest build is oldest running one
        expect(latestBuild.slug).to.equal(targetBuild.slug);
        expect(error).to.beNil();
    }];
}

- (void)testLatestBuildFetchMostRecentBuildIfNoRunning {
    [self executeOnStorage:^{
        // Add two finished builds
        BRAccount *acc = [self buildAccountWithToken:kAccountToken slug:kAccountSlug];
        BRApp *app = [self buildAppWithSlug:kAppSlug1 forAccount:acc];
        [self buildWithSlug:kBuildSlug1 staus:@(1) app:app];
        BRBuild *targetBuild = [self buildWithSlug:kBuildSlug2 staus:@(1) app:app];
        
        // Fetch latest build
        NSError *error;
        BRBuild *latestBuild = [self.storage latestBuild:app error:&error];
        
        // Verify latest build is most recent one
        expect(latestBuild.slug).to.equal(targetBuild.slug);
        expect(error).to.beNil();
    }];
}

- (void)testLatestBuildIsNilIfNoBuilds {
    [self executeOnStorage:^{
        // Fetch latest build
        BRAccount *acc = [self buildAccountWithToken:kAccountToken slug:kAccountSlug];
        BRApp *app = [self buildAppWithSlug:kAppSlug1 forAccount:acc];
        NSError *error;
        BRBuild *latestBuild = [self.storage latestBuild:app error:&error];
        
        // Verify latest build is nil
        expect(latestBuild).to.beNil();
        expect(error).to.beNil();
    }];
}

- (void)testSaveBuildsInsertsBuild {
    [self executeOnStorage:^{
        // Add build
        BRAccount *acc = [self buildAccountWithToken:kAccountToken slug:kAccountSlug];
        BRApp *app = [self buildAppWithSlug:kAppSlug1 forAccount:acc];
        BRBuildInfo *buildInfo = [self buildInfoWithSlug:kBuildSlug1 status:@(0)];
        NSError *error;
        BOOL result = [self.storage saveBuilds:@[buildInfo] forApp:app.slug error:&error];
        
        // Fetch it
        BRBuild *build = [self buildWithSlug:kBuildSlug1];
        
        // Verify build inserted and assigned to app
        expect(result).to.beTruthy();
        expect(build).to.beTruthy();
        expect(build.app.slug).to.equal(app.slug);
        expect(error).to.beNil();
    }];
}

- (void)testSaveBuildsUpdatesBuildIfExists {
    [self executeOnStorage:^{
        // Add build with status 0
        BRAccount *acc = [self buildAccountWithToken:kAccountToken slug:kAccountSlug];
        BRApp *app = [self buildAppWithSlug:kAppSlug1 forAccount:acc];
        [self buildWithSlug:kBuildSlug1 staus:@(0) app:app];
        
        // Update it with status 1
        BRBuildInfo *buildInfo = [self buildInfoWithSlug:kBuildSlug1 status:@(1)];
        NSError *error;
        BOOL result = [self.storage saveBuilds:@[buildInfo] forApp:app.slug error:&error];
        
        // Fetch updated
        BRBuild *updateBuild = [self buildWithSlug:kBuildSlug1];
        
        // Verify status was updated
        expect(updateBuild.status.integerValue).to.equal(1);
        expect(result).to.beTruthy();
        expect(error).to.beNil();
    }];
}

- (void)testSaveBuildsFailsIfNoAppsFound {
    [self executeOnStorage:^{
        BRBuildInfo *buildInfo = [self buildInfoWithSlug:kBuildSlug1 status:@(1)];
        NSError *error;
        BOOL result = [self.storage saveBuilds:@[buildInfo] forApp:kAppSlug1 error:&error];
        
        expect(result).to.beFalsy();
        expect(error).to.beNil();
    }];
}

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

- (BRBuild *)buildWithSlug:(NSString *)slug staus:(NSNumber *)status app:(BRApp *)app {
    if (!app) {
        BRAccount *acc = [self buildAccountWithToken:kAccountToken slug:kAccountSlug];
        app = [self buildAppWithSlug:kAppSlug1 forAccount:acc];
    }
    
    BRBuild *build = [NSEntityDescription insertNewObjectForEntityForName:@"BRBuild" inManagedObjectContext:self.context];
    build.slug = slug;
    build.status = status;
    build.triggerTime = [NSDate date];
    build.app = app;
    
    [self.context save:nil];
    
    return build;
}

- (BRAccountInfo *)accountInfo {
    return [[BRAccountInfo alloc] initWithResponse:@{ @"slug" : kAccountSlug } token:kAccountToken];
}

- (BRAppInfo *)appInfoWithSlug:(NSString *)slug {
    return [[BRAppInfo alloc] initWithResponse:@{ @"slug" : slug }];
}

- (BRBuildInfo *)buildInfoWithSlug:(NSString *)slug status:(NSNumber *)status {
    return [[BRBuildInfo alloc] initWithResponse:@{ @"status" : status,
                                                    @"is_on_hold" : @(0),
                                                    @"slug" : slug,
                                                    @"branch" : @"foo",
                                                    @"triggered_workflow" : @"bar" }];
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

- (BRBuild *)buildWithSlug:(NSString *)slug {
    NSFetchRequest *request = [BRBuild fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"slug == %@", slug];
    
    NSError *error;
    NSArray <BRBuild *> *builds = [self.context executeFetchRequest:request error:&error];
    
    return builds.firstObject;
}

@end
