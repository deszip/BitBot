//
//  BRRequestBuilder.h
//  Bitrise
//
//  Created by Deszip on 25/12/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRRequestBuilder : NSObject

- (NSURLRequest *)accountRequest:(NSString *)token;
- (NSURLRequest *)appsRequest:(NSString *)token;
- (NSURLRequest *)buildsRequest:(NSString *)slug token:(NSString *)token after:(NSTimeInterval)after;
- (NSURLRequest *)abortRequest:(NSString *)buildSlug appSlug:(NSString *)appSlug token:(NSString *)token;
- (NSURLRequest *)rebuildRequest:(NSString *)buildSlug appSlug:(NSString *)appSlug token:(NSString *)token;

@end

NS_ASSUME_NONNULL_END
