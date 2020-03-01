//
//  BRLogInfo.m
//  Bitrise
//
//  Created by Deszip on 16/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRLogInfo.h"

#import "NSArray+FRP.h"
#import "NSDictionary+FRP.h"

static NSString * const kLogURLKey = @"expiring_raw_log_url";
static NSString * const kChunksCountKey = @"generated_log_chunks_num";
static NSString * const kArchivedKey = @"is_archived";
static NSString * const kTimestampKey = @"timestamp";

static NSString * const kChunkListKey = @"log_chunks";
static NSString * const kChunkKey = @"chunk";
static NSString * const kChunkPositionKey = @"position";

@implementation BRLogInfo

- (instancetype)initWithRawLog:(NSDictionary *)rawLog {
    if (self = [super init]) {
        _rawLog = rawLog;
        
        NSString *logURLPath = rawLog[kLogURLKey];
        if (logURLPath && ![logURLPath isEqual:[NSNull null]]) {
            _logURL = [NSURL URLWithString:logURLPath];
        }
        
        NSNumber *chunksCount = rawLog[kChunksCountKey];
        if (![chunksCount isEqual:[NSNull null]]) {
            _chunksCount = [chunksCount integerValue];
        }
        
        NSNumber *archived = rawLog[kArchivedKey];
        if (![archived isEqual:[NSNull null]]) {
            _archived = [archived boolValue];
        }
        
        NSNumber *timestamp = rawLog[kTimestampKey];
        if (![timestamp isEqual:[NSNull null]]) {
            _timestamp = [timestamp doubleValue];
        }
    }
    
    return self;
}

- (NSString *)content {
    return [self contentExcluding:nil];
}

- (NSString *)contentExcluding:(NSIndexSet *)excludedChunks {
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey: kChunkPositionKey ascending:YES];
    NSArray *chunks = [self.rawLog[kChunkListKey] sortedArrayUsingDescriptors: @[sortDescriptor]];
    NSArray *lines = [chunks aps_map:^NSString *(NSDictionary *chunk) {
        if (![excludedChunks containsIndex:[chunk[kChunkPositionKey] integerValue]]) {
            return chunk[kChunkKey];
        }
        return @"";
    }];
    NSString *logContent = [lines componentsJoinedByString:@""];
    
    return logContent;
}

- (NSArray <NSDictionary *> *)chunksExcluding:(NSIndexSet *)excludedChunks {
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey: kChunkPositionKey ascending:YES];
    NSArray *chunks = [self.rawLog[kChunkListKey] sortedArrayUsingDescriptors: @[sortDescriptor]];
    
    return [chunks aps_filter:^BOOL(NSDictionary *chunk) {
        return ![excludedChunks containsIndex:[chunk[kChunkPositionKey] integerValue]];
    }];
}

- (NSIndexSet *)chunkPositions {
    __block NSMutableIndexSet *positions = [NSMutableIndexSet indexSet];
    [[self.rawLog[kChunkListKey] valueForKeyPath:@"position"] enumerateObjectsUsingBlock:^(NSNumber *chunkPosition, NSUInteger idx, BOOL *stop) {
        [positions addIndex:[chunkPosition integerValue]];
    }];
    
    return positions;
}

@end
