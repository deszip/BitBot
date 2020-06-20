//
//  BRAccountsObserver.h
//  Bitrise
//
//  Created by Deszip on 20.06.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, BRAccountsState) {
    BRAccountsStateEmpty = 0,
    BRAccountsStateHasData
};

typedef void(^BRAccountsStateCallback)(BRAccountsState state);

@interface BRAccountsObserver : NSObject

@property (assign, nonatomic, readonly) BRAccountsState state;

- (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithContainer:(NSPersistentContainer *)container NS_DESIGNATED_INITIALIZER;

- (void)start:(BRAccountsStateCallback)callback;

@end

NS_ASSUME_NONNULL_END
