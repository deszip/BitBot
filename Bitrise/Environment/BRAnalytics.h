//
//  BRAnalytics.h
//  Bitrise
//
//  Created by Deszip on 04/05/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRAnalytics : NSObject

#pragma mark - Init -

+ (instancetype)analytics;

// Controls if services are running
- (void)start;
- (void)stop;

// Controls if analytics is allowed by user
- (void)setEnabled:(BOOL)isEnabled;
- (BOOL)isEnabled;

// Switches enabled state and calls start/stop
- (void)toggle;

#pragma mark - Events -

- (void)trackFirstStartApp;
- (void)trackStartApp;
- (void)trackQuitApp;
- (void)trackPopoverOpen;
- (void)trackAboutOpen;
- (void)trackAccountsOpen;
- (void)trackAutorunToggle;
- (void)trackNotificationsToggle;
- (void)trackAnalyticsToggle;

- (void)trackAccountAdd;
- (void)trackAccountAddFailure:(NSError *)error;
- (void)trackAccountRemove;
- (void)trackAccountRemoveError:(NSError *)error;
- (void)trackSyncWithStarted:(NSUInteger)started
                     running:(NSUInteger)running
                    finished:(NSUInteger)finished;
- (void)trackSyncError:(NSError *)error;
- (void)trackRebuildAction;
- (void)trackAbortAction;
- (void)trackLoadLogsAction;
- (void)trackOpenBuildAction;

@end

NS_ASSUME_NONNULL_END
