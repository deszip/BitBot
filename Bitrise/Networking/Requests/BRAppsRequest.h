//
//  BRAppsRequest.h
//  Bitrise
//
//  Created by Deszip on 11/01/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRAPIRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRAppsRequest : BRAPIRequest

- (instancetype)initWithToken:(NSString *)token;

@end

NS_ASSUME_NONNULL_END
