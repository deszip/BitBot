//
//  BRLogStorage.h
//  Bitrise
//
//  Created by Deszip on 20/03/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BRBuildInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRLogStorage : NSObject

- (instancetype)initWithContext:(NSManagedObjectContext *)context;

- (BOOL)saveLogMetadata:(NSDictionary *)rawLogMetadata forBuild:(BRBuild *)build error:(NSError * __autoreleasing *)error;
- (BOOL)appendLogs:(NSString *)text chunkPosition:(NSUInteger)chunkPosition toBuild:(BRBuild *)build error:(NSError * __autoreleasing *)error;
- (BOOL)markBuildLog:(BRBuildLog *)buildLog loaded:(BOOL)isLoaded error:(NSError * __autoreleasing *)error;
- (BOOL)cleanLogs:(BRBuild *)build error:(NSError * __autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END
