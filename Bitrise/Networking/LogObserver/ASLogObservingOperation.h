//
//  ASLogLoadingOperation.h
//  Bitrise
//
//  Created by Deszip on 02/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "ASOperation.h"

#import "BRStorage.h"
#import "BRBitriseAPI.h"

NS_ASSUME_NONNULL_BEGIN

@interface ASLogObservingOperation : ASOperation

@property (copy, nonatomic, readonly) NSString *buildSlug;

- (instancetype)initWithStorage:(BRStorage *)storage api:(BRBitriseAPI *)api buildSlug:(NSString *)buildSlug;

@end

NS_ASSUME_NONNULL_END
