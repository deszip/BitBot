//
//  BRAnalytics.m
//  Bitrise
//
//  Created by Deszip on 04/05/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRAnalytics.h"

#import <Mixpanel_OSX_Community/Mixpanel.h>

static NSString * const kBRAnalyticsAvailabilityKey = @"kBRAnalyticsAvailabilityKey";

static NSString * const kBRSessionDurationKey = @"duration";
static NSString * const kBRStartedBuildsKey = @"started";
static NSString * const kBRRunningBuildsKey = @"running";
static NSString * const kBRFinishedBuildsKey = @"finished";

typedef NSString BRAnalyticsEvent;

static BRAnalyticsEvent * const kStartSessionEvent = @"session_started";
static BRAnalyticsEvent * const kEndSessionEvent = @"session_ended";
static BRAnalyticsEvent * const kQuitAppEvent = @"app_quit";
static BRAnalyticsEvent * const kPopoverOpenedEvent = @"popover_opened";
static BRAnalyticsEvent * const kAboutScreenEvent = @"app_showabout";
static BRAnalyticsEvent * const kAccountsScreenEvent = @"app_showaccounts";
static BRAnalyticsEvent * const kAutorunToggleEvent = @"app_autoruntoggle";
static BRAnalyticsEvent * const kNotificationsToggleEvent = @"app_notificationstoggle";
static BRAnalyticsEvent * const kAnalyticsToggleEvent = @"app_analyticstoggle";

static BRAnalyticsEvent * const kAddAccountEvent = @"account_add";
static BRAnalyticsEvent * const kRemoveAccountEvent = @"account_remove";
static BRAnalyticsEvent * const kSyncEvent = @"build_sync";

static BRAnalyticsEvent * const kRebuildActionEvent = @"action_rebuild";
static BRAnalyticsEvent * const kAbortActionEvent = @"action_abort";
static BRAnalyticsEvent * const kLoadLogsActionEvent = @"action_loadlogs";
static BRAnalyticsEvent * const kOpenBuildActionEvent = @"action_openbuild";

@interface BRAnalytics ()

@property (strong, nonatomic) NSUserDefaults *defaults;

@property (strong, nonatomic) NSDate *sessionStartDate;

@end

@implementation BRAnalytics

#pragma mark - Init -

- (instancetype)initWithDefaults:(NSUserDefaults *)defaults {
    if (self = [super init]) {
        _defaults = defaults;
    }
    
    return self;
}

+ (instancetype)analytics {
    static dispatch_once_t onceToken;
    static BRAnalytics *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BRAnalytics alloc] initWithDefaults:[NSUserDefaults standardUserDefaults]];
    });
    
    return sharedInstance;
}

- (void)start {
    [Mixpanel sharedInstanceWithToken:@"ae64ff4c78b73e7f945f63aa02677fbb"];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kBRAnalyticsAvailabilityKey] == nil) {
        [[BRAnalytics analytics] setEnabled:YES];
    }
}

- (void)toggle {
    [self setEnabled:![self isEnabled]];
}

- (void)setEnabled:(BOOL)isEnabled {
    [self.defaults setBool:isEnabled forKey:kBRAnalyticsAvailabilityKey];
    [self.defaults synchronize];
}

- (BOOL)isEnabled {
    return [self.defaults boolForKey:kBRAnalyticsAvailabilityKey];
}

#pragma mark - Events -

- (void)trackSessionStart {
    self.sessionStartDate = [NSDate date];
    [self sendEvent:kStartSessionEvent properties:@{}];
}

- (void)trackSessionEnd {
    NSTimeInterval sessionDuration = [[NSDate date] timeIntervalSinceDate:self.sessionStartDate];
    [self sendEvent:kEndSessionEvent properties:@{ kBRSessionDurationKey : @(sessionDuration) }];
    
}

- (void)trackQuitApp { [self sendEvent:kQuitAppEvent properties:@{}]; }
- (void)trackOpenPopover { [self sendEvent:kPopoverOpenedEvent properties:@{}]; }
- (void)trackAboutOpen { [self sendEvent:kAboutScreenEvent properties:@{}]; }
- (void)trackAccountsOpen { [self sendEvent:kAccountsScreenEvent properties:@{}]; }
- (void)trackAutorunToggle { [self sendEvent:kAutorunToggleEvent properties:@{}]; }
- (void)trackNotificationsToggle { [self sendEvent:kNotificationsToggleEvent properties:@{}]; }
- (void)trackAnalyticsToggle { [self sendEvent:kAnalyticsToggleEvent properties:@{}]; }

- (void)trackAccountAdd { [self sendEvent:kAddAccountEvent properties:@{}]; }
- (void)trackAccountRemove { [self sendEvent:kRemoveAccountEvent properties:@{}]; }
- (void)trackSyncWithStarted:(NSUInteger)started
                     running:(NSUInteger)running
                    finished:(NSUInteger)finished { [self sendEvent:kSyncEvent properties:@{ kBRStartedBuildsKey : @(started),
                                                                                             kBRRunningBuildsKey : @(running),
                                                                                             kBRFinishedBuildsKey : @(finished) }]; }

- (void)trackRebuildAction { [self sendEvent:kRebuildActionEvent properties:@{}]; }
- (void)trackAbortAction { [self sendEvent:kAbortActionEvent properties:@{}]; }
- (void)trackLoadLogsAction { [self sendEvent:kLoadLogsActionEvent properties:@{}]; }
- (void)trackOpenBuildAction { [self sendEvent:kOpenBuildActionEvent properties:@{}]; }

#pragma mark - Sending events -

- (void)sendEvent:(BRAnalyticsEvent *)name properties:(NSDictionary *)properties {
    if ([self isEnabled]) {
        [[Mixpanel sharedInstance] track:name properties:properties];
    }
}

@end
