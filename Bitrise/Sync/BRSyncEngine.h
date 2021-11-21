//
//  BRSyncEngine.h
//  BitBot
//
//  Created by Deszip on 06/12/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BRBitriseAPI;
#import "BRStorage.h"
#import "BRSyncResult.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^BREngineCallback)(NSError * __nullable error);

@interface BRSyncEngine : NSObject

- (instancetype)initWithAPI:(BRBitriseAPI *)api storage:(BRStorage *)storage;

- (void)sync;
- (void)syncAccounts;
- (void)addAccount:(NSString *)accountToken callback:(BREngineCallback)callback;

@property (copy, nonatomic, nullable) void (^syncCallback)(BRSyncResult *result);

@end

NS_ASSUME_NONNULL_END
