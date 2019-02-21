//
//  BRLogsWindowPresenter.h
//  Bitrise
//
//  Created by Deszip on 21/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

#import "BRBuildInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRLogsWindowPresenter : NSObject

- (instancetype)initWithPresentingController:(NSViewController *)controller;

- (void)presentLogs:(BRBuildInfo *)buildInfo;

@end

NS_ASSUME_NONNULL_END
