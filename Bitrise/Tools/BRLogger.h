//
//  BRLogger.h
//  BitBot
//
//  Created by Zardoz on 30.04.12.
//  Copyright (c) 2012 BitBot. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BRLog(level,tag_value,message,...) [[BRLogger defaultLogger] logLevel:level tag:tag_value file:__FILE__ lineNumber:__LINE__ format:(message),##__VA_ARGS__]

@class BRLogEntry;

// Log tags
static NSString * const LL_WEBSOCKET            = @"UI";
static NSString * const LL_REQUESTFLOW          = @"SYNC";
static NSString * const LL_STORAGE              = @"STORAGE";
static NSString * const LL_CORE                 = @"CORE";
static NSString * const LL_LOGSYNC              = @"LOGSYNC";


typedef NS_ENUM(NSUInteger, BRLogLevel) {
    LL_VERBOSE  = 1 << 0,
    LL_DEBUG    = 1 << 1,
    LL_INFO     = 1 << 2,
    LL_WARN     = 1 << 3,
    LL_ERROR    = 1 << 4,
    LL_ASSERT   = 1 << 5,
    
    LL_NONE     = NSUIntegerMax
};

@interface BRLogger : NSObject

@property (nonatomic, assign) BRLogLevel currentLogLevel;

+ (id)defaultLogger;

- (void)logLevel:(BRLogLevel)level tag:(NSString *)tag file:(char const *)sourceFile lineNumber:(int)lineNumber format:(NSString *)format, ...;

@end
