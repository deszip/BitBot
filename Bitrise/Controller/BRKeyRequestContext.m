//
//  BRKeyRequestContext.m
//  BitBot
//
//  Created by Deszip on 31/12/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRKeyRequestContext.h"

@implementation BRKeyRequestContext

- (instancetype)initWithType:(BRKeyRequestContextType)type appSlug:(NSString *)appSlug {
    if (self = [super init]) {
        _type = type;
        _appSlug = appSlug;
    }
    
    return self;
}

+ (instancetype)accountContext {
    return [[BRKeyRequestContext alloc] initWithType:BRKeyRequestContextTypeAccount appSlug:nil];
}

+ (instancetype)appContext:(NSString *)appSlug {
    return [[BRKeyRequestContext alloc] initWithType:BRKeyRequestContextTypeApp appSlug:appSlug];
}

@end
