//
//  BRStorage.m
//  BitBot
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRStorage.h"

#import <EasyMapping/EasyMapping.h>

#import "NSArray+FRP.h"
#import "BRMacro.h"

#import "BRAccount+Mapping.h"
#import "BRApp+Mapping.h"
#import "BRBuild+Mapping.h"
#import "BRBuildLog+Mapping.h"
#import "BRLogLine+CoreDataClass.h"

@interface BRStorage ()

@property (strong, nonatomic) NSManagedObjectContext *context;

@end

@implementation BRStorage

- (instancetype)initWithContext:(NSManagedObjectContext *)context {
    if (self = [super init]) {
        _context = context;
        [_context setAutomaticallyMergesChangesFromParent:YES];
    }
    
    return self;
}

#pragma mark - Synchronous API -

- (void)perform:(void (^)(void))action {
    [self.context performBlock:^{
        action();
    }];
}

#pragma mark - Accounts  -

- (NSArray <BRAccount *> *)accounts:(NSError * __autoreleasing *)error {
    NSFetchRequest *request = [BRAccount fetchRequest];
    NSArray *accounts = [self.context executeFetchRequest:request error:error];
    
    return accounts;
}

- (BOOL)saveAccount:(BRAccountInfo *)accountInfo error:(NSError * __autoreleasing *)error {
    BRAccount *account = [EKManagedObjectMapper objectFromExternalRepresentation:accountInfo.rawResponce withMapping:[BRAccount objectMapping] inManagedObjectContext:self.context];
    account.token = accountInfo.token;
    
    return [self saveContext:self.context error:error];
}

- (BOOL)removeAccount:(NSString *)slug error:(NSError * __autoreleasing *)error {
    NSFetchRequest *request = [BRAccount fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"slug = %@", slug];
    
    NSError *requestError = nil;
    NSArray *accounts = [self.context executeFetchRequest:request error:&requestError];
    if (accounts.count > 0) {
        [accounts enumerateObjectsUsingBlock:^(BRAccount *nextAccount, NSUInteger idx, BOOL *stop) {
            [self.context deleteObject:nextAccount];
        }];
        return [self saveContext:self.context error:error];
    } else {
        return NO;
    }
}

#pragma mark - Apps -

- (BOOL)updateApps:(NSArray <BRAppInfo *> *)appsInfo forAccount:(BRAccount *)account error:(NSError * __autoreleasing *)error {
    NSFetchRequest *request = [BRAccount fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"slug == %@", account.slug];
    NSError *requestError = nil;
    NSArray *accounts = [self.context executeFetchRequest:request error:&requestError];
    if (accounts.count == 1) {
        // Fetch and remove outdated account apps
        NSFetchRequest *request = [BRApp fetchRequest];
        NSArray *appSlugs = [appsInfo valueForKeyPath:@"slug"];
        request.predicate = [NSPredicate predicateWithFormat:@"account.slug == %@ AND NOT (slug IN %@)", account.slug, appSlugs];
        NSError *requestError = nil;
        NSArray *outdatedApps = [self.context executeFetchRequest:request error:&requestError];
        [outdatedApps enumerateObjectsUsingBlock:^(BRApp *app, NSUInteger idx, BOOL *stop) {
            [self.context deleteObject:app];
        }];
        
        // Insert new apps
        [appsInfo enumerateObjectsUsingBlock:^(BRAppInfo *appInfo, NSUInteger idx, BOOL *stop) {
            BRApp *app = [EKManagedObjectMapper objectFromExternalRepresentation:appInfo.rawResponse withMapping:[BRApp objectMapping] inManagedObjectContext:self.context];
            app.account = accounts[0];
            [self saveContext:self.context error:error];
        }];
        
        return YES;
    } else {
        return NO;
    }
}

- (NSArray <BRApp *> *)appsForAccount:(BRAccount *)account error:(NSError * __autoreleasing *)error {
    NSFetchRequest *request = [BRApp fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"account.slug == %@", account.slug];
    NSArray <BRApp *> *apps = [self.context executeFetchRequest:request error:error];
    
    return apps;
}

- (BOOL)addBuildToken:(NSString *)token toApp:(NSString *)appSlug error:(NSError * __autoreleasing *)error {
    NSFetchRequest *request = [BRApp fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"slug == %@", appSlug];
    NSArray <BRApp *> *apps = [self.context executeFetchRequest:request error:error];
    
    if (apps.count == 1) {
        [apps.firstObject setBuildToken:token];
        return [self saveContext:self.context error:error];
    }
    
    return NO;
}

#pragma mark - Builds -

- (BRBuild *)buildWithSlug:(NSString *)slug error:(NSError * __autoreleasing *)error {
    NSFetchRequest *request = [BRBuild fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"slug = %@", slug];
    
    NSArray <BRBuild *> *builds = [self.context executeFetchRequest:request error:error];
    if (builds.count == 1) {
        return builds.firstObject;
    }
    
    return nil;
}

- (NSArray <BRBuild *> *)runningBuilds:(NSError * __autoreleasing *)error {
    NSFetchRequest *request = [BRBuild fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"status = 0"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"triggerTime" ascending:NO]];
    
    NSArray <BRBuild *> *builds = [self.context executeFetchRequest:request error:error];
    
    return builds;
}

- (BRBuild *)latestBuild:(BRApp *)app error:(NSError * __autoreleasing *)error {
    NSFetchRequest *request = [BRBuild fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"app.slug == %@ && status == 0", app.slug];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"triggerTime" ascending:YES]];
    request.fetchLimit = 1;
    
    NSArray <BRBuild *> *runningBuilds = [self.context executeFetchRequest:request error:error];
    
    // If we have running builds return oldest, otherwise - most recent build
    if (runningBuilds.count > 0) {
        return [runningBuilds firstObject];
    } else {
        NSFetchRequest *request = [BRBuild fetchRequest];
        request.predicate = [NSPredicate predicateWithFormat:@"app.slug == %@ && status != 0", app.slug];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"triggerTime" ascending:NO]];
        request.fetchLimit = 1;
        
        NSArray <BRBuild *> *finishedBuilds = [self.context executeFetchRequest:request error:error];
        if (finishedBuilds.count > 0) {
            return finishedBuilds.firstObject;
        }
    }
    
    return nil;
}

- (BOOL)saveBuilds:(NSArray <BRBuildInfo *> *)buildsInfo forApp:(NSString *)appSlug error:(NSError * __autoreleasing *)error {
    NSFetchRequest *request = [BRApp fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"slug == %@", appSlug];
    NSArray *apps = [self.context executeFetchRequest:request error:error];
    __block BOOL result = YES;
    if (apps.count == 1) {
        [buildsInfo enumerateObjectsUsingBlock:^(BRBuildInfo *buildInfo, NSUInteger idx, BOOL *stop) {
            BRBuild *build = [EKManagedObjectMapper objectFromExternalRepresentation:buildInfo.rawResponse withMapping:[BRBuild objectMapping] inManagedObjectContext:self.context];
            build.app = apps[0];
        }];
        result = [self saveContext:self.context error:error];
    } else {
        NSLog(@"Failed to save builds: %@", *error);
        result = NO;
    }
    
    return result;
}

#pragma mark - Logs -

- (BOOL)saveLogMetadata:(NSDictionary *)rawLogMetadata forBuild:(BRBuild *)build error:(NSError * __autoreleasing *)error {
    if (build.log) {
        [EKManagedObjectMapper fillObject:build.log fromExternalRepresentation:rawLogMetadata withMapping:[BRBuildLog objectMapping] inManagedObjectContext:self.context];
    } else {
        BRBuildLog *buildLog = [EKManagedObjectMapper objectFromExternalRepresentation:rawLogMetadata withMapping:[BRBuildLog objectMapping] inManagedObjectContext:self.context];
        build.log = buildLog;
    }
    
    return [self saveContext:self.context error:error];
}

// @TODO: Extract text processing
- (BOOL)appendLogs:(NSString *)text chunkPosition:(NSUInteger)chunkPosition toBuild:(BRBuild *)build error:(NSError * __autoreleasing *)error {
    // Get last line
    // BRBuild *build, return BRLogLine if was broken or nil
    NSFetchRequest *request = [BRLogLine fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"log.build.slug = %@", build.slug];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"chunkPosition" ascending:NO],
                                [NSSortDescriptor sortDescriptorWithKey:@"linePosition" ascending:NO]];
    request.fetchLimit = 1;
    NSError *fetchError;
    NSArray<BRLogLine *> *lines = [self.context executeFetchRequest:request error:&fetchError];
    
    BRLogLine *lastLine = nil;
    BOOL lineBroken = NO;
    if (lines.count == 1) {
        lastLine = lines.firstObject;
        lineBroken = [[lastLine.text substringFromIndex:lastLine.text.length - 1] rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound;
    }
    
    // Split chunk into lines
    NSMutableArray <NSString *> *rawLines = [[text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] mutableCopy];
    rawLines = [[rawLines aps_map:^NSString *(NSString *line) {
        if (line.length > 0 && ![rawLines.lastObject isEqualToString:line]) {
            return [line stringByAppendingString:@"\n"];
        }
        
        return line;
    }] mutableCopy];
    
    // If input has newline as a last symbol we'll have empty line at the end, drop it
    if (rawLines.lastObject.length == 0) {
        [rawLines removeLastObject];
    }
    
    // Append first line to previous line if it was broken
    if (lineBroken && rawLines.count > 0) {
        lastLine.text = [lastLine.text stringByAppendingString:rawLines.firstObject];
        [rawLines removeObjectAtIndex:0];
    }
    
    // Build rest of lines from chunk
    // NSArray <NSString *> *lines, BRBuild *build
    [rawLines enumerateObjectsUsingBlock:^(NSString *rawLine , NSUInteger idx, BOOL *stop) {
        BRLogLine *line = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([BRLogLine class]) inManagedObjectContext:self.context];
        line.linePosition = idx;
        line.chunkPosition = chunkPosition;
        line.text = rawLine;
        [build.log addLinesObject:line];
    }];
    
    return [self saveContext:self.context error:error];
}

- (BOOL)markBuildLog:(BRBuildLog *)buildLog loaded:(BOOL)isLoaded error:(NSError * __autoreleasing *)error {
    [buildLog setLoaded:isLoaded];
    
    return [self saveContext:self.context error:error];
}

- (BOOL)cleanLogs:(NSString *)buildSlug error:(NSError * __autoreleasing *)error {
    // Mark build as not loaded
    BRBuild *build = [self buildWithSlug:buildSlug error:error];
    if (!build) {
        return NO;
    }
    build.log.loaded = NO;
    
    // Clean logs
    NSFetchRequest *linesRequest = [BRLogLine fetchRequest];
    [linesRequest setPredicate:[NSPredicate predicateWithFormat:@"log.build.slug = %@", buildSlug]];
    NSArray <BRLogLine *> *lines = [self.context executeFetchRequest:linesRequest error:error];
    if (!lines) {
        return NO;
    }
    [lines enumerateObjectsUsingBlock:^(BRLogLine *line, NSUInteger idx, BOOL *stop) {
        [self.context deleteObject:line];
    }];
    
    return [self saveContext:self.context error:error];
}

#pragma mark - Save -

- (BOOL)saveContext:(NSManagedObjectContext *)context error:(NSError * __autoreleasing *)error {
    if ([context hasChanges]) {
        [context processPendingChanges];
        return [context save:error];
    }
    
    return YES;
}

@end
