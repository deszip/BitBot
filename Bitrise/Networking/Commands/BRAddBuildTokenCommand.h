//
//  BRAddBuildKeyCommand.h
//  Bitrise
//
//  Created by Deszip on 03/01/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRCommand.h"

#import "BRStorage.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRAddBuildTokenCommand : BRCommand

- (instancetype)initWithStorage:(BRStorage *)storage appSlug:(NSString *)appSlug token:(NSString *)token;

@end

NS_ASSUME_NONNULL_END
