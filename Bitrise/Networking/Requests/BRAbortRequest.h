//
//  BRAbortRequest.h
//  Bitrise
//
//  Created by Deszip on 10/01/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRAPIRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRAbortRequest : BRAPIRequest

- (instancetype)initWithToken:(NSString *)token appSlug:(NSString *)appSlug buildSlug:(NSString *)buildSlug NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
