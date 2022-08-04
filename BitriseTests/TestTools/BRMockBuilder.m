//
//  BRMockBuilder.m
//  BitriseTests
//
//  Created by Deszip on 24/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRMockBuilder.h"

@interface BRMockBuilder ()

@property (strong, nonatomic) NSManagedObjectContext *context;

@end

@implementation BRMockBuilder

- (instancetype)initWithContext:(NSManagedObjectContext *)context {
    if (self = [super init]) {
        _context = context;
    }
    
    return self;
}

#pragma mark - CD Models -

- (BTRAccount *)buildAccountWithToken:(NSString *)token slug:(NSString *)slug {
    BTRAccount *account = [NSEntityDescription insertNewObjectForEntityForName:@"BTRAccount" inManagedObjectContext:self.context];
    account.token = token;
    account.slug = slug;
    
    [self.context save:nil];
    
    return account;
}

- (BRApp *)buildAppWithSlug:(NSString *)slug forAccount:(BTRAccount *)account {
    BRApp *app = [NSEntityDescription insertNewObjectForEntityForName:@"BRApp" inManagedObjectContext:self.context];
    app.slug = slug;
    app.account = account;
    
    [self.context save:nil];
    
    return app;
}

- (BRBuild *)buildWithSlug:(NSString *)slug status:(NSNumber *)status app:(BRApp *)app {
    if (!app) {
        BTRAccount *acc = [self buildAccountWithToken:kAccountToken slug:kAccountSlug];
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

- (BRBuildLog *)logForBuild:(BRBuild *)build {
    BRBuildLog *buildLog = [NSEntityDescription insertNewObjectForEntityForName:@"BRBuildLog" inManagedObjectContext:self.context];
    build.log = buildLog;
    
    return buildLog;
}

#pragma mark - Models -

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

#pragma mark - Fetch -

- (BRBuild *)buildWithSlug:(NSString *)slug {
    NSFetchRequest *request = [BRBuild fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"slug == %@", slug];
    
    NSError *error;
    NSArray <BRBuild *> *builds = [self.context executeFetchRequest:request error:&error];
    
    return builds.firstObject;
}

#pragma mark - CD Models Update -

- (BRApp *)updateApp:(BRApp *)app {
    app.title = [[NSUUID UUID] UUIDString];
    [self.context save:nil];
    
    return app;
}

@end
