//
//  BRObserver.h
//  Bitrise
//
//  Created by Deszip on 13/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BRCommand.h"
#import "BRBitriseAPI.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRObserver : NSObject

- (void)startObserving:(id <BRCommand>)command;
- (void)stopObserving;

@end

NS_ASSUME_NONNULL_END
