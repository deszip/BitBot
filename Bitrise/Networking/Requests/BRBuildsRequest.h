//
//  BRBuildsRequest.h
//  Bitrise
//
//  Created by Deszip on 10/01/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRAPIRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRBuildsRequest : BRAPIRequest

- (instancetype)initWithToken:(NSString *)token appSlug:(NSString *)appSlug syncTime:(NSTimeInterval)syncTime;

@end

NS_ASSUME_NONNULL_END
