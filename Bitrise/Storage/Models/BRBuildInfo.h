//
//  BRBuildInfo.h
//  Bitrise
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRBuildInfo : NSObject

@property (strong, nonatomic, readonly) NSDictionary *rawResponse;

- (instancetype)initWithResponse:(NSDictionary *)response;

@end

NS_ASSUME_NONNULL_END
