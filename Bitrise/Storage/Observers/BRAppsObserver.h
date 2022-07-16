//
//  BRAppsObserver.h
//  Bitrise
//
//  Created by Deszip on 16.07.2022.
//  Copyright © 2022 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BTRAccount+CoreDataClass.h"
#import "BRApp+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, BRAppState) {
    BRAppStateEmpty = 0,
    BRAppStateHasData
};

typedef void(^BRAppStateCallback)(BRAppState state);
typedef void(^BRAppUpdateCallback)(BRApp *app);

@interface BRAppsObserver : NSObject

@property (assign, nonatomic, readonly) BRAppState state;

- (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithContext:(NSManagedObjectContext *)context NS_DESIGNATED_INITIALIZER;

- (void)startStateObserving:(BRAppStateCallback)callback;
- (void)startAppObserving:(NSString *)appSlug callback:(BRAppUpdateCallback)callback;

@end

NS_ASSUME_NONNULL_END
