//
//  BRLogInfo.m
//  Bitrise
//
//  Created by Deszip on 16/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRLogInfo.h"

#import "NSArray+FRP.h"

@interface BRLogInfo ()

@property (strong, nonatomic) NSDictionary *rawLog;

@end

@implementation BRLogInfo

- (instancetype)initWithRawLog:(NSDictionary *)rawLog {
    if (self = [super init]) {
        _rawLog = rawLog;
    }
    
    return self;
}

- (NSString *)content {
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey: @"position" ascending:YES];
    NSArray *chunks = [self.rawLog[@"log_chunks"] sortedArrayUsingDescriptors: @[sortDescriptor]];
    NSArray *lines = [chunks aps_map:^NSString *(NSDictionary *chunk) {
        return chunk[@"chunk"];
    }];
    NSString *logContent = [lines componentsJoinedByString:@""];
    
    return logContent;
}

@end
