//
//  BRAppsRequest.m
//  Bitrise
//
//  Created by Deszip on 11/01/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRAppsRequest.h"

@implementation BRAppsRequest

- (instancetype)initWithToken:(NSString *)token {
    return [super initWithEndpoint:[NSURL URLWithString:kAppsEndpoint] token:token body:nil];
}

@end
