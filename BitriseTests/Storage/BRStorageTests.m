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
        NSArray <BTRAccount *> *accounts = [self.storage accounts:&error];
        expect(accounts.count).to.equal(0);
    }];
}

- (void)testStorageFetchesAccounts {
    [self.mockBuilder buildAccountWithToken:kAccountToken slug:kAccountSlug];
    
    [self executeOnStorage:^{
        NSError *error;
        NSArray <BTRAccount *> *accounts = [self.storage accounts:&error];
        
        expect(accounts.count).to.equal(1);
        expect(accounts[0].token).to.equal(kAccountToken);
    }];
}

- (void)testStorageSavesAccount {
    [self executeOnStorage:^{
        NSError *error;
        [self.storage saveAccount:[self.mockBuilder accountInfo] error:&error];
        expect(error).to.beNil();
        
        NSArray <BTRAccount *> *accounts = [self.storage accounts:&error];
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
        
        NSArray <BTRAccount *> *accounts = [self.storage accounts:&error];
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
        NSArray <BTRAccount *> *accounts = [self.storage accounts:nil];
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
        NSArray <BTRAccount *> *accounts = [self.storage accounts:nil];
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
        NSArray <BTRAccount *> *accounts = [self.storage accounts:nil];
        NSError *error;
        BOOL result = [self.storage updateApps:@[[self.mockBuilder appInfoWithSlug:kAppSlug1]] forAccount:accounts[0] error:&error];
        
        expect(result).to.beFalsy();
    }];
}

- (void)testStorageFetchesApps {
    [self executeOnStorage:^{
        BTRAccount *account = [self.mockBuilder buildAccountWithToken:kAccountToken slug:kAccountSlug];
        [self.mockBuilder buildAppWithSlug:kAppSlug1 forAccount:account];
        
        NSError *error;
        NSArray <BRApp *> *apps = [self.storage appsForAccount:account error:&error];
        expect(apps.count).to.equal(1);
        expect(apps[0].slug).to.equal(kAppSlug1);
    }];
}

- (void)testStorageFetchesEmptyAppsList {
    [self executeOnStorage:^{
        BTRAccount *account = [self.mockBuilder buildAccountWithToken:kAccountToken slug:kAccountSlug];
        
        NSError *error;
        NSArray <BRApp *> *apps = [self.storage appsForAccount:account error:&error];
        expect(apps.count).to.equal(0);
    }];
}

- (void)testStorageAddsBuildToken {
    [self executeOnStorage:^{
        BTRAccount *account = [self.mockBuilder buildAccountWithToken:kAccountToken slug:kAccountSlug];
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
        BTRAccount *account = [self.mockBuilder buildAccountWithToken:kAccountToken slug:kAccountSlug];
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
        BTRAccount *acc = [self.mockBuilder buildAccountWithToken:kAccountToken slug:kAccountSlug];
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
        BTRAccount *acc = [self.mockBuilder buildAccountWithToken:kAccountToken slug:kAccountSlug];
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
        BTRAccount *acc = [self.mockBuilder buildAccountWithToken:kAccountToken slug:kAccountSlug];
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
        BTRAccount *acc = [self.mockBuilder buildAccountWithToken:kAccountToken slug:kAccountSlug];
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
        BTRAccount *acc = [self.mockBuilder buildAccountWithToken:kAccountToken slug:kAccountSlug];
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
        BTRAccount *acc = [self.mockBuilder buildAccountWithToken:kAccountToken slug:kAccountSlug];
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
    [self executeOnStorageWithPrebuiltLog:^(BRBuild *build) {
        NSDictionary *logMetadata = [self.logStubBuilder runningLogMetadata];
        NSError *error;
        BOOL result = [self.storage saveLogMetadata:logMetadata forBuild:build error:&error];
        
        expect(result).to.beTruthy();
        expect(error).to.beFalsy();
        expect(build.log.loaded).to.beFalsy();
        [self validateLogMetadata:build.log metadata:logMetadata];
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
        [self validateLogMetadata:build.log metadata:logMetadata];
    }];
}

- (void)testStorageAppendsFirstLogLine {
    [self executeOnStorageWithPrebuiltLog:^(BRBuild *build) {
        NSError *error;
        BOOL result = [self.storage appendLogs:@"line1\nline2\nline3" chunkPosition:0 toBuild:build error:&error];
        
        expect(result).to.beTruthy();
        expect(error).to.beFalsy();
        expect(build.log.lines.count).to.equal(3);
    }];
}

- (void)testStorageAppendsLinesToExistingLog {
    [self executeOnStorageWithPrebuiltLog:^(BRBuild *build) {
        NSError *error;
        [self.storage appendLogs:@"line1\nline2\n" chunkPosition:0 toBuild:build error:&error];
        BOOL result = [self.storage appendLogs:@"line3\nline4\n" chunkPosition:1 toBuild:build error:&error];
        
        expect(result).to.beTruthy();
        expect(error).to.beFalsy();
        expect(build.log.lines.count).to.equal(4);
        
        NSArray <BRLogLine *> *lines = [self sortedLines:build.log];
        expect(lines[0].chunkPosition).to.equal(0);
        expect(lines[0].linePosition).to.equal(0);
        expect(lines[1].chunkPosition).to.equal(0);
        expect(lines[1].linePosition).to.equal(1);
        expect(lines[2].chunkPosition).to.equal(1);
        expect(lines[2].linePosition).to.equal(0);
        expect(lines[3].chunkPosition).to.equal(1);
        expect(lines[3].linePosition).to.equal(1);
    }];
}

- (void)testStorageAppendsBrokenLines {
    [self executeOnStorageWithPrebuiltLog:^(BRBuild *build) {
        NSError *error;
        [self.storage appendLogs:@"line1\nline2 which is " chunkPosition:0 toBuild:build error:&error];
        BOOL result = [self.storage appendLogs:@"broken\nline3" chunkPosition:1 toBuild:build error:&error];
        
        expect(result).to.beTruthy();
        expect(error).to.beFalsy();
        expect(build.log.lines.count).to.equal(3);
        
        NSArray <BRLogLine *> *lines = [self sortedLines:build.log];
        expect(lines[1].text).equal(@"line2 which is broken\n");
    }];
}

- (void)testStorageAppendsEmptyLines {
    [self executeOnStorageWithPrebuiltLog:^(BRBuild *build) {
        NSError *error;
        [self.storage appendLogs:@"line1\nline2\n" chunkPosition:0 toBuild:build error:&error];
        BOOL result = [self.storage appendLogs:@"line3\n\n" chunkPosition:1 toBuild:build error:&error];
        
        expect(result).to.beTruthy();
        expect(error).to.beFalsy();
        expect(build.log.lines.count).to.equal(4);
        
        NSArray <BRLogLine *> *lines = [self sortedLines:build.log];
        expect(lines[3].text).equal(@"");
    }];
}

- (void)testStorageHandlesLatEmptyLine {
    [self executeOnStorageWithPrebuiltLog:^(BRBuild *build) {
        NSError *error;
        [self.storage appendLogs:@"line1\nline2\n\n" chunkPosition:0 toBuild:build error:&error];
        BOOL result = [self.storage appendLogs:@"line3" chunkPosition:1 toBuild:build error:&error];
        
        expect(result).to.beTruthy();
        expect(error).to.beFalsy();
        expect(build.log.lines.count).to.equal(4);
        
        NSArray <BRLogLine *> *lines = [self sortedLines:build.log];
        expect(lines[2].text).equal(@"");
    }];
}

- (void)testStorageMarksLogAsLoaded {
    [self executeOnStorageWithPrebuiltLog:^(BRBuild *build) {
        NSError *error;
        [self.storage markBuildLog:build.log loaded:YES error:&error];
        expect(build.log.loaded).to.beTruthy();
        
        [self.storage markBuildLog:build.log loaded:NO error:&error];
        expect(build.log.loaded).to.beFalsy();
    }];
}

- (void)testStorageCleansLog {
    [self executeOnStorageWithPrebuiltLog:^(BRBuild *build) {
        NSError *error;
        [self.storage appendLogs:@"line1\nline2" chunkPosition:0 toBuild:build error:&error];
        
        BOOL result = [self.storage cleanLogs:build error:&error];
        
        expect(result).to.beTruthy();
        expect(error).to.beNil();
        expect(build.log.lines.count).to.equal(0);
    }];
}

- (void)testStorageMarksLogAsNotLoadedAfterClean {
    [self executeOnStorageWithPrebuiltLog:^(BRBuild *build) {
        NSError *error;
        [self.storage cleanLogs:build error:&error];
        
        expect(build.log.loaded).to.beFalsy();
    }];
}

#pragma mark - Tools -

- (void)executeOnStorageWithPrebuiltLog:(void (^)(BRBuild *))action {
    XCTestExpectation *e = [self expectationWithDescription:@""];
    
    [self.storage perform:^{
        BRBuild *build = [self.mockBuilder buildWithSlug:kBuildSlug1 status:@(0) app:nil];
        __unused BRBuildLog *log = [self.mockBuilder logForBuild:build];
        action(build);
        [e fulfill];
    }];
    
    [self waitForExpectations:@[e] timeout:0.1];
}

- (void)executeOnStorage:(void (^)(void))action {
    XCTestExpectation *e = [self expectationWithDescription:@""];
    
    [self.storage perform:^{
        action();
        [e fulfill];
    }];
    
    [self waitForExpectations:@[e] timeout:0.1];
}

- (void)validateLogMetadata:(BRBuildLog *)log metadata:(NSDictionary *)logMetadata {
    expect(log.archived).to.equal([logMetadata[@"is_archived"] boolValue]);
    expect(log.chunksCount).to.equal([logMetadata[@"generated_log_chunks_num"] integerValue]);
    if (logMetadata[@"expiring_raw_log_url"] != [NSNull null]) {
        expect(log.expiringRawLogURL).to.equal(logMetadata[@"expiring_raw_log_url"]);
    } else {
        expect(log.expiringRawLogURL).to.beNil();
    }
    expect(log.timestamp).to.equal([NSDate dateWithTimeIntervalSince1970:[logMetadata[@"timestamp"] doubleValue]]);
}

- (NSArray <BRLogLine *> *)sortedLines:(BRBuildLog *)log {
    return [log.lines sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"chunkPosition" ascending:YES],
                                             [NSSortDescriptor sortDescriptorWithKey:@"linePosition" ascending:YES]]];
}

@end
