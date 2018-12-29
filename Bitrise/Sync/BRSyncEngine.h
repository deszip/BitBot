//
//  BRSyncEngine.h
//  Bitrise
//
//  Created by Deszip on 06/12/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BRBitriseAPI.h"
#import "BRStorage.h"
#import "BRSyncResult.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRSyncEngine : NSObject

- (instancetype)initWithAPI:(BRBitriseAPI *)api storage:(BRStorage *)storage;

- (void)sync;
- (void)addAccount:(NSString *)accountToken;

@property (copy, nonatomic, nullable) void (^syncCallback)(BRSyncResult *result);

@end

NS_ASSUME_NONNULL_END
