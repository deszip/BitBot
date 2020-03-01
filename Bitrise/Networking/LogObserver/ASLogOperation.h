//
//  ASLogOperation.h
//  Bitrise
//
//  Created by Deszip on 20/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#ifndef ASLogOperation_h
#define ASLogOperation_h

@class BRStorage;
@class BRBitriseAPI;

@protocol ASLogOperation <NSObject>

@required
@property (copy, nonatomic, readonly) NSString *buildSlug;
- (instancetype)initWithStorage:(BRStorage *)storage api:(BRBitriseAPI *)api buildSlug:(NSString *)buildSlug;

@end

#endif /* ASLogOperation_h */
