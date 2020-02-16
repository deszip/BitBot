//
//  BRLogsParser.m
//  Bitrise
//
//  Created by Deszip on 26/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRLogsParser.h"

#import "AMR_ANSIEscapeHelper.h"
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

//- (NSArray *)colorChunks:(NSString *)input {
//    __block NSMutableArray *chunks = [NSMutableArray array];
//
//    NSError *error;
//        //NSRegularExpression *colorRegex = [NSRegularExpression regularExpressionWithPattern:@"\\e.(\\d{1,1};)??(\\d{1,2}m)" options:NSRegularExpressionUseUnixLineSeparators error:&error];
//    NSRegularExpression *colorRegex = [NSRegularExpression regularExpressionWithPattern:@"\\e.(\\d{1,1};)??(\\d{1,2}m)" options:NSRegularExpressionUseUnixLineSeparators error:&error];
//
//    NSArray *matches = [colorRegex matchesInString:input options:NSMatchingReportProgress range:NSMakeRange(0, [input length])];
//    NSString *colorStrippedString = [colorRegex stringByReplacingMatchesInString:input options:0 range:NSMakeRange(0,[input length]) withTemplate:@""];
//    //NSMutableAttributedString *attributedResult = [[NSMutableAttributedString alloc] initWithString:[colorStrippedString stringByAppendingString:@"\r\n"]];
//    //[attributedResult addAttributes:*attrs range:NSMakeRange(0, [colorStrippedString length])];
//
//    [colorRegex enumerateMatchesInString:input options:NSMatchingReportProgress range:NSMakeRange(0, [input length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
//        if (result) {
//            //NSRange rangeToHandle = NSMakeRange([result rangeAtIndex:1].location-1, [result rangeAtIndex:1].length+1);
//            NSString *subString = [input substringWithRange:result.range];
//            [chunks addObject:subString];
//        }
//    }];
//
//    return [chunks copy];
//}

- (NSAttributedString *)coloredLine:(NSString *)input {
    AMR_ANSIEscapeHelper *helper = [AMR_ANSIEscapeHelper new];
    return [helper attributedStringWithANSIEscapedString:input];
}

@end
