//
//  BRStorage.m
//  Bitrise
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BRStorage.h"

#import <EasyMapping/EasyMapping.h>

#import "BRAccount+Mapping.h"

@interface BRStorage ()

@property (strong, nonatomic) NSPersistentContainer *container;

@end

@implementation BRStorage

- (instancetype)initWithContainer:(NSPersistentContainer *)container {
    if (self = [super init]) {
        _container = container;
    }
    
    return self;
}

- (void)saveAccount:(BRAccountInfo *)accountInfo {
    [self.container performBackgroundTask:^(NSManagedObjectContext *context) {
        [context setAutomaticallyMergesChangesFromParent:YES];
        BRAccount *account = [EKManagedObjectMapper objectFromExternalRepresentation:accountInfo.rawResponce withMapping:[BRAccount objectMapping] inManagedObjectContext:context];
        account.token = accountInfo.token;
        
        [self saveContext:context];
    }];
}

- (void)removeAccount:(NSString *)token {
    [self.container performBackgroundTask:^(NSManagedObjectContext *context) {
        NSFetchRequest *request = [BRAccount fetchRequest];
        request.predicate = [NSPredicate predicateWithFormat:@"token = %@", token];
        
        NSError *requestError = nil;
        NSArray *accounts = [context executeFetchRequest:request error:&requestError];
        if (accounts) {
            [accounts enumerateObjectsUsingBlock:^(BRAccount *nextAccount, NSUInteger idx, BOOL *stop) {
                [context deleteObject:nextAccount];
            }];
            [self saveContext:context];
        } else {
            NSLog(@"Failed to fetch account: %@", requestError);
        }
    }];
}

- (void)getAccounts:(BRAccountsListResult)completion {
    [self.container performBackgroundTask:^(NSManagedObjectContext *context) {
        NSFetchRequest *request = [BRAccount fetchRequest];
        NSError *requestError = nil;
        NSArray *accounts = [context executeFetchRequest:request error:&requestError];
        if (accounts) {
            
            __block NSMutableArray *accountInfos = [NSMutableArray array];
            [accounts enumerateObjectsUsingBlock:^(BRAccount *nextAccount, NSUInteger idx, BOOL *stop) {
                [accountInfos addObject:[[BRAccountInfo alloc] initWithAccount:nextAccount]];
            }];
            
            completion(accountInfos, nil);
        } else {
            completion(nil, requestError);
        }
    }];
}

- (void)saveBuilds:(NSArray <BRBuildInfo *> *)buildsInfo {
    [self.container performBackgroundTask:^(NSManagedObjectContext *context) {
        
    }];
}

#pragma mark - Save -

- (void)saveContext:(NSManagedObjectContext *)context {
    if ([context hasChanges]) {
        NSError *saveError = nil;
        if (![context save:&saveError]) {
            NSLog(@"Failed to save context: %@", saveError);
        }
    }
}

@end
