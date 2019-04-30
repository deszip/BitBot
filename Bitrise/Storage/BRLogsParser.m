//
//  BRLogsParser.m
//  Bitrise
//
//  Created by Deszip on 26/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRLogsParser.h"

#import "NSArray+FRP.h"

@implementation BRLogsParser

- (BOOL)lineBroken:(NSString *)line {
    if (line.length == 0) {
        return NO;
    }
    
    return [[line substringFromIndex:line.length - 1] rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound;
}

- (NSArray <NSString *> *)split:(NSString * _Nullable)logChunk {
    // Split chunk into lines
    NSMutableArray <NSString *> *rawLines = [[logChunk componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] mutableCopy];
    rawLines = [[rawLines aps_map:^NSString *(NSString *line) {
        if (line.length > 0 && ![rawLines.lastObject isEqualToString:line]) {
            return [line stringByAppendingString:@"\n"];
        }
        
        return line;
    }] mutableCopy];
    
    // If input has newline as a last symbol we'll have empty line at the end, drop it
    if (rawLines.lastObject.length == 0) {
        [rawLines removeLastObject];
    }
    
    return [rawLines copy];
}

- (NSString *)stepNameForLine:(NSString *)line {
    NSError *error;
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"^([|])\\s+([(])([0-9]+)([)])\\s+(.*)\\s+([|])$" options:0 error:&error];
    NSTextCheckingResult *result = [expression firstMatchInString:line options:0 range:NSMakeRange(0, line.length)];
    
    if (result && result.numberOfRanges == 7) {
        NSString *stepName = [[line substringWithRange:[result rangeAtIndex:5]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        return stepName;
    }
    
    return nil;
}

@end
