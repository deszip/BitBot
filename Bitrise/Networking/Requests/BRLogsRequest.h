//
//  BRLogsRequest.h
//  Bitrise
//
//  Created by Deszip on 02/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRAPIRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRLogsRequest : BRAPIRequest

- (instancetype)initWithToken:(NSString *)token appSlug:(NSString *)appSlug buildSlug:(NSString *)buildSlug since:(NSTimeInterval)since NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
