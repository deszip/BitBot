//
//  BRKeyRequestContext.h
//  Bitrise
//
//  Created by Deszip on 31/12/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, BRKeyRequestContextType) {
    BRKeyRequestContextTypeUndefined = 0,
    BRKeyRequestContextTypeAccount,
    BRKeyRequestContextTypeApp
};

@interface BRKeyRequestContext : NSObject

@property (assign, nonatomic, readonly) BRKeyRequestContextType type;
@property (copy, nonatomic, readonly, nullable) NSString *appSlug;

- (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)accountContext;
+ (instancetype)appContext:(NSString *)appSlug;

@end

NS_ASSUME_NONNULL_END
