//
//  BRSyncResult.h
//  Bitrise
//
//  Created by Deszip on 21/12/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BRAppInfo.h"
#import "BRSyncDiff.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRSyncResult : NSObject

@property (strong, nonatomic, readonly) BRAppInfo *app;
@property (strong, nonatomic, readonly) BRSyncDiff *diff;

- (instancetype)initWithApp:(BRAppInfo *)appInfo diff:(BRSyncDiff *)diff;

@end

NS_ASSUME_NONNULL_END
