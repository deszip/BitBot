//
//  BRAPIRequest.h
//  Bitrise
//
//  Created by Deszip on 09/01/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRAPIRequest : NSObject

@property (copy, nonatomic, readonly) NSString *token;
@property (strong, nonatomic, readonly) NSURL *endpoint;
@property (strong, nonatomic, readonly, nullable) NSData *requestBody;

- (instancetype)initWithEndpoint:(NSURL *)endpoint token:(NSString *)token body:(NSData * _Nullable)body;

- (NSString *)method;
- (NSURLRequest *)urlRequest;

@end

NS_ASSUME_NONNULL_END
