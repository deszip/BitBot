//
//  BRAnalytics.m
//  Bitrise
//
//  Created by Deszip on 04/05/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRAnalytics.h"

#import <Mixpanel/Mixpanel.h>

static NSString * const kBRAnalyticsAvailabilityKey = @"kBRAnalyticsAvailabilityKey";

static NSString * const kBRMixpanelOSXToken = @"ae64ff4c78b73e7f945f63aa02677fbb";
static NSString * const kBRMixpanelATVToken = @"4d209b738bd7dc6965ad1325080f83f1";

typedef NSString BRAnalyticsEvent;

static BRAnalyticsEvent * const kQuitAppEvent = @"app_quit";
static BRAnalyticsEvent * const kAboutScreenEvent = @"app_showabout";
static BRAnalyticsEvent * const kAccountsScreenEvent = @"app_showaccounts";
static BRAnalyticsEvent * const kAutorunToggleEvent = @"app_autoruntoggle";
static BRAnalyticsEvent * const kNotificationsToggleEvent = @"app_notificationstoggle";
static BRAnalyticsEvent * const kAnalyticsToggleEvent = @"app_analyticstoggle";

static BRAnalyticsEvent * const kAddAccountEvent = @"account_add";
static BRAnalyticsEvent * const kAddAccountFailureEvent = @"account_add_failure";
static BRAnalyticsEvent * const kRemoveAccountEvent = @"account_remove";
static BRAnalyticsEvent * const kSyncEvent = @"build_sync";

static BRAnalyticsEvent * const kRebuildActionEvent = @"action_rebuild";
static BRAnalyticsEvent * const kAbortActionEvent = @"action_abort";
static BRAnalyticsEvent * const kLoadLogsActionEvent = @"action_loadlogs";
static BRAnalyticsEvent * const kOpenBuildActionEvent = @"action_openbuild";

@interface BRAnalytics ()

@property (strong, nonatomic) NSUserDefaults *defaults;

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
#if TARGET_OS_OSX
    [Mixpanel sharedInstanceWithToken:kBRMixpanelOSXToken];
#else
    [Mixpanel sharedInstanceWithToken:kBRMixpanelATVToken];
#endif
    
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

- (void)trackQuitApp { [self sendEvent:kQuitAppEvent properties:@{}]; }
- (void)trackAboutOpen { [self sendEvent:kAboutScreenEvent properties:@{}]; }
- (void)trackAccountsOpen { [self sendEvent:kAccountsScreenEvent properties:@{}]; }
- (void)trackAutorunToggle { [self sendEvent:kAutorunToggleEvent properties:@{}]; }
- (void)trackNotificationsToggle { [self sendEvent:kNotificationsToggleEvent properties:@{}]; }
- (void)trackAnalyticsToggle { [self sendEvent:kAnalyticsToggleEvent properties:@{}]; }

- (void)trackAccountAdd { [self sendEvent:kAddAccountEvent properties:@{}]; }
- (void)trackAccountAddFailure { [self sendEvent:kAddAccountFailureEvent properties:@{}]; }
- (void)trackAccountRemove { [self sendEvent:kRemoveAccountEvent properties:@{}]; }
- (void)trackSyncWithStarted:(NSUInteger)started
                     running:(NSUInteger)running
                    finished:(NSUInteger)finished { [self sendEvent:kSyncEvent properties:@{ @"started" : @(started),
                                                                                             @"running" : @(running),
                                                                                             @"finished" : @(finished) }]; }

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
