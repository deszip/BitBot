//
//  BRAccountRequest.m
//  Bitrise
//
//  Created by Deszip on 11/01/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRAccountRequest.h"

@implementation BRAccountRequest

- (instancetype)initWithToken:(NSString *)token {
    return [super initWithEndpoint:[NSURL URLWithString:kAccountInfoEndpoint] token:token body:nil];
}

@end
