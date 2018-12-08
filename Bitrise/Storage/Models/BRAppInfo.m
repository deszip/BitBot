//
//  BRAppInfo.m
//  Bitrise
//
//  Created by Deszip on 08/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BRAppInfo.h"

@implementation BRAppInfo

- (instancetype)initWithResponse:(NSDictionary *)response {
    if (self = [super init]) {
        _rawResponse = response;
        _slug = _rawResponse[@"slug"];
    }
    
    return self;
}

- (instancetype)initWithApp:(BRApp *)app {
    if (self = [super init]) {
        _rawResponse = nil;
        _slug = app.slug;
    }
    
    return self;
}

@end
