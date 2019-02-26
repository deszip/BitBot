//
//  BRLogsParser.h
//  Bitrise
//
//  Created by Deszip on 26/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRLogsParser : NSObject

- (BOOL)lineBroken:(NSString * _Nullable)line;
- (NSArray <NSString *> *)split:(NSString * _Nullable)logChunk;

@end

NS_ASSUME_NONNULL_END
