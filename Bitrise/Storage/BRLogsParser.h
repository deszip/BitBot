//
//  BRLogsParser.h
//  Bitrise
//
//  Created by Deszip on 26/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BRLogsParser : NSObject

- (BOOL)lineBroken:(NSString *)line;
- (NSArray <NSString *> *)split:(NSString *)logChunk;
- (NSString *)stepNameForLine:(NSString *)line;

@end
