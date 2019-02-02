//
//  BRBuildActionContext.h
//  Bitrise
//
//  Created by Deszip on 02/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRBuildActionContext : NSObject

@property (copy, nonatomic, readonly) NSString *slug;

+ (instancetype)contextWithSlug:(NSString *)buildSlug;

@end

NS_ASSUME_NONNULL_END
