//
//  BRLogStubBuilder.h
//  BitriseTests
//
//  Created by Deszip on 24/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRLogStubBuilder : NSObject

- (NSDictionary *)runningLogMetadata;
- (NSDictionary *)finishedLogMetadata;

@end

NS_ASSUME_NONNULL_END
