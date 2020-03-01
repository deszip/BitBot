//
//  BRLogsDataSource.h
//  Bitrise
//
//  Created by Deszip on 10/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "BRLogPresenter.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRLogsDataSource : NSObject

@property (copy, nonatomic) void (^updateCallback)(NSString *log);
@property (copy, nonatomic) void (^insertCallback)(NSString *log);

- (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithContainer:(NSPersistentContainer *)container
                     logPresenter:(BRLogPresenter *)presenter NS_DESIGNATED_INITIALIZER;
- (void)fetch:(NSString *)buildSlug;
- (void)bindOutlineView:(NSOutlineView *)outlineView;
- (void)bindTextView:(NSTextView *)textView;

@end

NS_ASSUME_NONNULL_END
