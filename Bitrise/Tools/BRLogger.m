//
//  BRLogger.m
//  BitBot
//
//  Created by Zardoz on 30.04.12.
//  Copyright (c) 2012 BitBot. All rights reserved.
//

#import "BRLogger.h"

void BR_Raw_NSLog(NSString *format, ...) {
    va_list ap;
    va_start(ap, format);
    NSLogv(format, ap);
    va_end(ap);
}

@implementation BRLogger

+ (id)defaultLogger {
    static BRLogger *defaultLogger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultLogger = [BRLogger new];
        [defaultLogger setCurrentLogLevel:LL_NONE];
    });
    
    return defaultLogger;
}

- (void)logLevel:(BRLogLevel)level tag:(NSString *)tag file:(const char *)sourceFile lineNumber:(int)lineNumber format:(NSString *)format, ... {
    // Skip if log level is lower than current
    if ([[BRLogger defaultLogger] currentLogLevel] > level) return;
    
    // Pass to system logging
    va_list args;
    va_start(args, format);
    NSString *logMessage = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    NSString *fileName = [[NSString alloc] initWithBytes:sourceFile length:strlen(sourceFile) encoding:NSUTF8StringEncoding];
    BR_Raw_NSLog(@"[%s:%d] %@ - %@", [[fileName lastPathComponent] UTF8String], lineNumber, tag, logMessage);
}

@end
