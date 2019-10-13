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

- (void)start;
- (void)toggle;
- (void)setEnabled:(BOOL)isEnabled;
- (BOOL)isEnabled;

#pragma mark - Events -

- (void)trackSessionStart;
- (void)trackSessionEnd;
- (void)trackQuitApp;
- (void)trackOpenPopover;
- (void)trackAboutOpen;
- (void)trackAccountsOpen;
- (void)trackAutorunToggle;
- (void)trackNotificationsToggle;
- (void)trackAnalyticsToggle;

- (void)trackAccountAdd;
- (void)trackAccountRemove;
- (void)trackSyncWithStarted:(NSUInteger)started
                     running:(NSUInteger)running
                    finished:(NSUInteger)finished;
- (void)trackRebuildAction;
- (void)trackAbortAction;
- (void)trackLoadLogsAction;
- (void)trackOpenBuildAction;

@end

NS_ASSUME_NONNULL_END
