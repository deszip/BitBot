//
//  BRLogsDataSource.h
//  Bitrise
//
//  Created by Deszip on 10/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRLogsDataSource : NSObject

@property (copy, nonatomic) void (^updateCallback)(NSString *log);

- (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithContainer:(NSPersistentContainer *)container NS_DESIGNATED_INITIALIZER;
- (void)fetch:(NSString *)buildSlug;

@end

NS_ASSUME_NONNULL_END
