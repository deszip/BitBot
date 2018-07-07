//
//  BRStorage.h
//  Bitrise
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "BRAccountResponse.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^BRStorageTokenslListResult)(NSArray <NSString *> * _Nullable, NSError * _Nullable);

@interface BRStorage : NSObject

- (instancetype)initWithContainer:(NSPersistentContainer *)container;

- (void)saveAccount:(BRAccountResponse *)accountInfo;
- (void)removeAccount:(NSString *)token;
- (void)getAccountTokens:(BRStorageTokenslListResult)completion;

@end

NS_ASSUME_NONNULL_END
