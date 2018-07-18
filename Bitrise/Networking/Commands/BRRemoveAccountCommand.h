//
//  BRRemoveAccountCommand.h
//  Bitrise
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BRCommand.h"
#import "BRStorage.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRRemoveAccountCommand : NSObject <BRCommand>

- (instancetype)initWithStorage:(BRStorage *)storage token:(NSString *)token;

@end

NS_ASSUME_NONNULL_END
