//
//  BRSyncCommand.h
//  BitBot
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BRCommand.h"
#import "BRSyncEngine.h"
#import "BRLogObserver.h"
#if TARGET_OS_OSX
#import "BREnvironment.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface BRSyncCommand : BRCommand

- (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

#if TARGE_OS_OSX
- (instancetype)initSyncEngine:(BRSyncEngine *)engine environment:(BREnvironment *)environment NS_DESIGNATED_INITIALIZER;
#else
- (instancetype)initSyncEngine:(BRSyncEngine *)engine NS_DESIGNATED_INITIALIZER;
#endif

@end

NS_ASSUME_NONNULL_END
