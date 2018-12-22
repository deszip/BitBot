//
//  BREnvironment.h
//  Bitrise
//
//  Created by Deszip on 21/12/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

#import "BRAutorun.h"
#import "BRAppInfo.h"
#import "BRBuildInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface BREnvironment : NSObject

- (instancetype)initWithAutorun:(BRAutorun *)autorun;

- (void)postNotifications:(NSArray<BRBuildInfo *> *)builds forApp:(BRAppInfo *)appInfo;

- (BOOL)autolaunchEnabled;
- (void)toggleAutolaunch;

- (void)quitApp;

@end

NS_ASSUME_NONNULL_END
