//
//  BRGetAccountCommand.h
//  Bitrise
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BRCommand.h"
#import "BRBitriseAPI.h"
#import "BRStorage.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRGetAccountCommand : NSObject <BRCommand>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithAPI:(BRBitriseAPI *)api storage:(BRStorage *)storage token:(NSString *)token NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
