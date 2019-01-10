//
//  BRRequestBuilder.h
//  BitBot
//
//  Created by Deszip on 25/12/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BRAbortRequest.h"
#import "BRRebuildRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRRequestBuilder : NSObject

- (NSURLRequest *)accountRequest:(NSString *)token;

- (NSURLRequest *)appsRequest:(NSString *)token;

//- (NSURLRequest *)buildsRequest:(NSString *)slug
//                          token:(NSString *)token
//                          after:(NSTimeInterval)after;

//- (NSURLRequest *)abortRequest:(NSString *)buildSlug
//                       appSlug:(NSString *)appSlug
//                         token:(NSString *)token;

//- (NSURLRequest *)abortURLRequest:(BRAbortRequest *)apiRequest;
//- (NSURLRequest *)rebuildURLRequest:(BRRebuildRequest *)apiRequest;

@end

NS_ASSUME_NONNULL_END
