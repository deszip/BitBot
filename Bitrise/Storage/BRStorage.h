//
//  BRStorage.h
//  Bitrise
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "BRAccountInfo.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^BRAccountsListResult)(NSArray <BRAccountInfo *> * _Nullable, NSError * _Nullable);

@interface BRStorage : NSObject

- (instancetype)initWithContainer:(NSPersistentContainer *)container;

- (void)saveAccount:(BRAccountInfo *)accountInfo;
- (void)removeAccount:(NSString *)token;
- (void)getAccounts:(BRAccountsListResult)completion;

@end

NS_ASSUME_NONNULL_END
