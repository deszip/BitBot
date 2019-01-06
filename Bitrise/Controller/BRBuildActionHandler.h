//
//  BRBuildActionHandler.h
//  BitBot
//
//  Created by Deszip on 05/08/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BRBitriseAPI.h"
#import "BRStorage.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRBuildActionHandler : NSObject

- (instancetype)initWithApi:(BRBitriseAPI *)api storage:(BRStorage *)storage;

- (void)rebuild:(NSString *)buildSlug;
- (void)abort:(NSString *)buildSlug;
- (void)downloadLog:(NSString *)buildSlug;
- (void)openBuild:(NSString *)buildSlug;
    
@end

NS_ASSUME_NONNULL_END
