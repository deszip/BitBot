//
//  BRLogInfo.h
//  Bitrise
//
//  Created by Deszip on 16/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRLogInfo : NSObject

@property (strong, nonatomic) NSDictionary *rawLog;
@property (strong, nonatomic, readonly) NSURL *logURL;
@property (assign, nonatomic, readonly) NSUInteger chunksCount;
@property (assign, nonatomic, readonly) BOOL archived;
@property (assign, nonatomic, readonly) NSTimeInterval timestamp;

- (instancetype)initWithRawLog:(NSDictionary *)rawLog;

- (NSString *)content;
- (NSString *)contentExcluding:(NSIndexSet * _Nullable)excludedChunks;
- (NSArray <NSDictionary *> *)chunksExcluding:(NSIndexSet * _Nullable)excludedChunks;
- (NSIndexSet *)chunkPositions;

@end

NS_ASSUME_NONNULL_END
