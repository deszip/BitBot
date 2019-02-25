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
#import "BRMockBuilder.h"
#import "BRLogStubBuilder.h"

#import "BRContainerBuilder.h"
#import "BRStorage.h"

@interface BRStorageTests : XCTestCase

@property (strong, nonatomic) NSPersistentContainer *container;
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) BRMockBuilder *mockBuilder;
@property (strong, nonatomic) BRLogStubBuilder *logStubBuilder;

@property (strong, nonatomic) BRStorage *storage;

@end

@implementation BRStorageTests

- (void)setUp {
    [super setUp];

    self.container = [[BRContainerBuilder new] buildContainerOfType:NSInMemoryStoreType];
    self.context = [self.container newBackgroundContext];
    self.mockBuilder = [[BRMockBuilder alloc] initWithContext:self.context];
    self.logStubBuilder = [BRLogStubBuilder new];
    
    self.storage = [[BRStorage alloc] initWithContext:self.context];
}

- (void)tearDown {
    self.container = nil;
    self.context = nil;
    self.mockBuilder = nil;
    self.logStubBuilder = nil;
    
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
    [self.mockBuilder buildAccountWithToken:kAccountToken slug:kAccountSlug];
    
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
        [self.storage saveAccount:[self.mockBuilder accountInfo] error:&error];
        expect(error).to.beNil();
        
        NSArray <BRAccount *> *accounts = [self.storage accounts:&error];
        expect(accounts.count).to.equal(1);
        expect(accounts[0].token).to.equal(kAccountToken);
    }];
}

- (void)testStorageRemovesAccount {
    [self.mockBuilder buildAccountWithToken:kAccountToken slug:kAccountSlug];
    
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
    [self.mockBuilder buildAccountWithToken:kAccountToken slug:kAccountSlug];
    
    [self executeOnStorage:^{
        NSArray <BRAccount *> *accounts = [self.storage accounts:nil];
        NSError *error;
        [self.storage updateApps:@[[self.mockBuilder appInfoWithSlug:kAppSlug1]] forAccount:accounts[0] error:&error];
        
        NSArray <BRApp *> *apps = [self.storage appsForAccount:accounts[0] error:&error];
        expect(apps.count).to.equal(1);
    }];
}

- (void)testStorageRemovesOutdatedApps {
    [self.mockBuilder buildAccountWithToken:kAccountToken slug:kAccountSlug];
    
    [self executeOnStorage:^{
        // Insert app 1
        NSArray <BRAccount *> *accounts = [self.storage accounts:nil];
        NSError *error;
        [self.storage updateApps:@[[self.mockBuilder appInfoWithSlug:kAppSlug1]] forAccount:accounts[0] error:&error];
        
        // Update with app 2
        [self.storage updateApps:@[[self.mockBuilder appInfoWithSlug:kAppSlug2]] forAccount:accounts[0] error:&error];
        
        // Verify only app 2 left in storage
        NSArray <BRApp *> *apps = [self.storage appsForAccount:accounts[0] error:&error];
        expect(apps.count).to.equal(1);
        expect(apps[0].slug).to.equal(kAppSlug2);
    }];
}

- (void)testStorageIgnoresDuplicateAccounts {
    [self.mockBuilder buildAccountWithToken:kAccountToken slug:kAccountSlug];
    [self.mockBuilder buildAccountWithToken:kAccountToken slug:kAccountSlug];
    
    [self executeOnStorage:^{
        NSArray <BRAccount *> *accounts = [self.storage accounts:nil];
        NSError *error;
        BOOL result = [self.storage updateApps:@[[self.mockBuilder appInfoWithSlug:kAppSlug1]] forAccount:accounts[0] error:&error];
        
        expect(result).to.beFalsy();
    }];
}

- (void)testStorageFetchesApps {
    [self executeOnStorage:^{
        BRAccount *account = [self.mockBuilder buildAccountWithToken:kAccountToken slug:kAccountSlug];
        [self.mockBuilder buildAppWithSlug:kAppSlug1 forAccount:account];
        
        NSError *error;
        NSArray <BRApp *> *apps = [self.storage appsForAccount:account error:&error];
        expect(apps.count).to.equal(1);
        expect(apps[0].slug).to.equal(kAppSlug1);
    }];
}

- (void)testStorageFetchesEmptyAppsList {
    [self executeOnStorage:^{
        BRAccount *account = [self.mockBuilder buildAccountWithToken:kAccountToken slug:kAccountSlug];
        
        NSError *error;
        NSArray <BRApp *> *apps = [self.storage appsForAccount:account error:&error];
        expect(apps.count).to.equal(0);
    }];
}

- (void)testStorageAddsBuildToken {
    [self executeOnStorage:^{
        BRAccount *account = [self.mockBuilder buildAccountWithToken:kAccountToken slug:kAccountSlug];
        [self.mockBuilder buildAppWithSlug:kAppSlug1 forAccount:account];
        
        NSError *error;
        BOOL result = [self.storage addBuildToken:kAppBuildToken toApp:kAppSlug1 error:&error];
        NSArray <BRApp *> *apps = [self.storage appsForAccount:account error:&error];
        expect(result).to.beTruthy();
        expect(apps[0].buildToken).to.equal(kAppBuildToken);
    }];
}

- (void)testStorageIgnoresAppDuplicate {
    [self executeOnStorage:^{
        BRAccount *account = [self.mockBuilder buildAccountWithToken:kAccountToken slug:kAccountSlug];
        [self.mockBuilder buildAppWithSlug:kAppSlug1 forAccount:account];
        [self.mockBuilder buildAppWithSlug:kAppSlug1 forAccount:account];
        
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
        [self.mockBuilder buildWithSlug:kBuildSlug1 status:@(0) app:nil];
        [self.mockBuilder buildWithSlug:kBuildSlug2 status:@(1) app:nil];
        NSError *error;
        BRBuild *build = [self.storage buildWithSlug:kBuildSlug1 error:&error];

        expect(build.slug).to.equal(kBuildSlug1);
        expect(error).to.beNil();
    }];
}

- (void)testStorageReturnsNilIfNoBuildFound {
    [self executeOnStorage:^{
        [self.mockBuilder buildWithSlug:kBuildSlug1 status:@(0) app:nil];
        NSError *error;
        BRBuild *build = [self.storage buildWithSlug:kBuildSlug2 error:&error];
        
        expect(build).to.beNil();
        expect(error).to.beNil();
    }];
}

- (void)testStorageReturnsNilIfDuplicateFound {
    [self executeOnStorage:^{
        [self.mockBuilder buildWithSlug:kBuildSlug1 status:@(0) app:nil];
        [self.mockBuilder buildWithSlug:kBuildSlug1 status:@(0) app:nil];
        NSError *error;
        BRBuild *build = [self.storage buildWithSlug:kBuildSlug1 error:&error];
        
        expect(build).to.beNil();
        expect(error).to.beNil();
    }];
}

- (void)testStorageFetchesRunningBuilds {
    [self executeOnStorage:^{
        [self.mockBuilder buildWithSlug:kBuildSlug1 status:@(0) app:nil];
        [self.mockBuilder buildWithSlug:kBuildSlug2 status:@(1) app:nil];
        NSError *error;
        NSArray <BRBuild *> *builds = [self.storage runningBuilds:&error];
        
        expect(builds.count).to.equal(1);
        expect(error).to.beNil();
        expect(builds[0].status.integerValue).to.equal(0);
    }];
}

- (void)testStorageSortsRunningBuilds {
    [self executeOnStorage:^{
        [self.mockBuilder buildWithSlug:kBuildSlug1 status:@(0) app:nil];
        [self.mockBuilder buildWithSlug:kBuildSlug2 status:@(0) app:nil];
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
        BRAccount *acc = [self.mockBuilder buildAccountWithToken:kAccountToken slug:kAccountSlug];
        BRApp *app = [self.mockBuilder buildAppWithSlug:kAppSlug1 forAccount:acc];
        BRBuild *finishedBuild = [self.mockBuilder buildWithSlug:kBuildSlug1 status:@(1) app:app];
        [self.mockBuilder buildWithSlug:kBuildSlug1 status:@(0) app:app];
        
        NSError *error;
        BRBuild *latestBuild = [self.storage latestBuild:app error:&error];
        
        expect(latestBuild.slug).to.equal(finishedBuild.slug);
        expect(error).to.beNil();
    }];
}

- (void)testLatestBuildFetchOldestRunningBuild {
    [self executeOnStorage:^{
        // Add four builds, only first and last are finished
        BRAccount *acc = [self.mockBuilder buildAccountWithToken:kAccountToken slug:kAccountSlug];
        BRApp *app = [self.mockBuilder buildAppWithSlug:kAppSlug1 forAccount:acc];
        [self.mockBuilder buildWithSlug:kBuildSlug1 status:@(1) app:app];
        BRBuild *targetBuild = [self.mockBuilder buildWithSlug:kBuildSlug2 status:@(0) app:app];
        [self.mockBuilder buildWithSlug:kBuildSlug3 status:@(0) app:app];
        [self.mockBuilder buildWithSlug:kBuildSlug4 status:@(1) app:app];
        
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
        BRAccount *acc = [self.mockBuilder buildAccountWithToken:kAccountToken slug:kAccountSlug];
        BRApp *app = [self.mockBuilder buildAppWithSlug:kAppSlug1 forAccount:acc];
        [self.mockBuilder buildWithSlug:kBuildSlug1 status:@(1) app:app];
        BRBuild *targetBuild = [self.mockBuilder buildWithSlug:kBuildSlug2 status:@(1) app:app];
        
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
        BRAccount *acc = [self.mockBuilder buildAccountWithToken:kAccountToken slug:kAccountSlug];
        BRApp *app = [self.mockBuilder buildAppWithSlug:kAppSlug1 forAccount:acc];
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
        BRAccount *acc = [self.mockBuilder buildAccountWithToken:kAccountToken slug:kAccountSlug];
        BRApp *app = [self.mockBuilder buildAppWithSlug:kAppSlug1 forAccount:acc];
        BRBuildInfo *buildInfo = [self.mockBuilder buildInfoWithSlug:kBuildSlug1 status:@(0)];
        NSError *error;
        BOOL result = [self.storage saveBuilds:@[buildInfo] forApp:app.slug error:&error];
        
        // Fetch it
        BRBuild *build = [self.mockBuilder buildWithSlug:kBuildSlug1];
        
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
        BRAccount *acc = [self.mockBuilder buildAccountWithToken:kAccountToken slug:kAccountSlug];
        BRApp *app = [self.mockBuilder buildAppWithSlug:kAppSlug1 forAccount:acc];
        [self.mockBuilder buildWithSlug:kBuildSlug1 status:@(0) app:app];
        
        // Update it with status 1
        BRBuildInfo *buildInfo = [self.mockBuilder buildInfoWithSlug:kBuildSlug1 status:@(1)];
        NSError *error;
        BOOL result = [self.storage saveBuilds:@[buildInfo] forApp:app.slug error:&error];
        
        // Fetch updated
        BRBuild *updateBuild = [self.mockBuilder buildWithSlug:kBuildSlug1];
        
        // Verify status was updated
        expect(updateBuild.status.integerValue).to.equal(1);
        expect(result).to.beTruthy();
        expect(error).to.beNil();
    }];
}

- (void)testSaveBuildsFailsIfNoAppsFound {
    [self executeOnStorage:^{
        BRBuildInfo *buildInfo = [self.mockBuilder buildInfoWithSlug:kBuildSlug1 status:@(1)];
        NSError *error;
        BOOL result = [self.storage saveBuilds:@[buildInfo] forApp:kAppSlug1 error:&error];
        
        expect(result).to.beFalsy();
        expect(error).to.beNil();
    }];
}

#pragma mark - Logs -

- (void)testStorageUpdatesLogMetadata {
    [self executeOnStorage:^{
        BRBuild *build = [self.mockBuilder buildWithSlug:kBuildSlug1 status:@(0) app:nil];
        BRBuildLog *log = [self.mockBuilder logForBuild:build];
        
        NSDictionary *logMetadata = [self.logStubBuilder runningLogMetadata];
        NSError *error;
        BOOL result = [self.storage saveLogMetadata:logMetadata forBuild:build error:&error];
        
        expect(result).to.beTruthy();
        expect(error).to.beFalsy();
        expect(log.loaded).to.beFalsy();
        expect(log.build).to.equal(build);
        [self validateLog:log metadata:logMetadata];
    }];
}

- (void)testStorageCreatesLogIfNotExists {
    [self executeOnStorage:^{
        BRBuild *build = [self.mockBuilder buildWithSlug:kBuildSlug1 status:@(0) app:nil];
        
        NSDictionary *logMetadata = [self.logStubBuilder runningLogMetadata];
        NSError *error;
        BOOL result = [self.storage saveLogMetadata:logMetadata forBuild:build error:&error];
        
        expect(result).to.beTruthy();
        expect(error).to.beFalsy();
        expect(build.log).to.beTruthy();
        [self validateLog:build.log metadata:logMetadata];
    }];
}

- (void)testStorageAppendsFirstLogLine {
    [self executeOnStorage:^{
        BRBuild *build = [self.mockBuilder buildWithSlug:kBuildSlug1 status:@(0) app:nil];
        BRBuildLog *log = [self.mockBuilder logForBuild:build];
        
        NSError *error;
        BOOL result =  [self.storage appendLogs:@"" chunkPosition:0 toBuild:build error:&error];
        
        expect(result).to.beTruthy();
        expect(error).to.beFalsy();
    }];
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

- (void)validateLog:(BRBuildLog *)log metadata:(NSDictionary *)logMetadata {
    expect(log.archived).to.equal([logMetadata[@"is_archived"] boolValue]);
    expect(log.chunksCount).to.equal([logMetadata[@"generated_log_chunks_num"] integerValue]);
    if (logMetadata[@"expiring_raw_log_url"] != [NSNull null]) {
        expect(log.expiringRawLogURL).to.equal(logMetadata[@"expiring_raw_log_url"]);
    } else {
        expect(log.expiringRawLogURL).to.beNil();
    }
    expect(log.timestamp).to.equal([NSDate dateWithTimeIntervalSince1970:[logMetadata[@"timestamp"] doubleValue]]);
}

@end
