//
//  BRAccountInfo.h
//  BitBot
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BTRAccount+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRAccountInfo : NSObject

@property (strong, nonatomic, readonly) NSDictionary *rawResponce;

@property (copy, nonatomic, readonly) NSString *token;
@property (copy, nonatomic, readonly) NSString *username;
@property (copy, nonatomic, readonly) NSString *slug;
@property (strong, nonatomic, readonly) NSURL *avatarURL;

- (instancetype)initWithResponse:(NSDictionary *)response token:(NSString *)token;
- (instancetype)initWithAccount:(BTRAccount *)account;

@end

NS_ASSUME_NONNULL_END
