//
//  BRStatsViewController.m
//  BitBot
//
//  Created by Deszip on 24.08.2022.
//  Copyright © 2022 Bitrise. All rights reserved.
//

#import "BRStatsViewController.h"

@import Charts;

#import "BRLogger.h"
#import "BTRAccount+CoreDataClass.h"
#import "BRApp+CoreDataClass.h"
#import "BRAppsObserver.h"
#import "BRStyleSheet.h"

@interface BRStatsViewController ()

@property (strong, nonatomic) BRAccountsObserver *accountObserver;
@property (strong, nonatomic) BRAppsObserver *appsObserver;
@property (strong, nonatomic) NSNotificationCenter *notificationCenter;

@property (weak) IBOutlet BarChartView *chartView1;
@property (weak) IBOutlet BarChartView *chartView2;
@property (weak) IBOutlet BarChartView *chartView3;
@property (weak) IBOutlet BarChartView *chartView4;
@property (weak) IBOutlet BarChartView *chartView5;

@end

@implementation BRStatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _accountObserver = [self.dependencyContainer accountsObserver];
    _appsObserver = [self.dependencyContainer appsObserver];
    
    _notificationCenter = [self.dependencyContainer notificationCenter];
    [self.notificationCenter addObserver:self selector:@selector(handleAccountSelection:) name:kAccountSelectedNotification object:nil];
    [self.notificationCenter addObserver:self selector:@selector(handleAppSelection:) name:kAppSelectedNotification object:nil];
}

#pragma mark - Notifications -

- (void)handleAccountSelection:(NSNotification *)notification {
    NSString *accSlug = notification.userInfo[@"AccountID"];
    BRLog(LL_VERBOSE, LL_UI, @"Account selected: %@", accSlug);
    
    [self.accountObserver startAccountObserving:accSlug callback:^(BTRAccount *account) {
        [self loadDataForAccount:account];
    }];
}

- (void)handleAppSelection:(NSNotification *)notification {
    NSString *appSlug = notification.userInfo[@"AppID"];
    BRLog(LL_VERBOSE, LL_UI, @"App selected: %@", appSlug);
    
    [self.appsObserver startAppObserving:appSlug callback:^(BRApp *app) {
        [self loadDataForApp:app];
    }];
}

#pragma mark - Data loading -

- (void)loadDataForApp:(BRApp *)app {
//    __block NSMutableArray <BarChartDataEntry *> *entries = [NSMutableArray array];
//    [app.builds enumerateObjectsUsingBlock:^(BRBuild *build, BOOL *stop) {
//        BarChartDataEntry *entry = [[BarChartDataEntry alloc] initWithX:build.buildNumber.doubleValue
//                                                                      y:[build.finishedTime timeIntervalSinceDate:build.startTime]];
//        [entries addObject:entry];
//    }];
//
//    BarChartDataSet *dataSet = [[BarChartDataSet alloc] initWithEntries:entries label:app.title];
//    BarChartData *chartData = [[BarChartData alloc] initWithDataSet:dataSet];
    
//    [self loadCharts:chartData];
    
    self.chartView1.data = [self buildStatusDataFor:app];
    self.chartView4.data = [self buildTimeDataFor:app];
}

- (void)loadDataForAccount:(BTRAccount *)account {
//    __block NSMutableArray <BarChartDataEntry *> *entries = [NSMutableArray array];
//    __block NSUInteger index = 0;
//    [account.apps enumerateObjectsUsingBlock:^(BRApp *app, BOOL *stop) {
//        BarChartDataEntry *entry = [[BarChartDataEntry alloc] initWithX:app.builds.count y:index];
//        [entries addObject:entry];
//        ++index;
//    }];
//
//    BarChartDataSet *dataSet = [[BarChartDataSet alloc] initWithEntries:entries label:account.username];
//    BarChartData *chartData = [[BarChartData alloc] initWithDataSet:dataSet];
//
//    [self loadCharts:chartData];
}

- (void)loadCharts:(BarChartData *)chartData {
    self.chartView1.data = chartData;
    self.chartView2.data = chartData;
    self.chartView3.data = chartData;
    self.chartView4.data = chartData;
    self.chartView5.data = chartData;
}

#pragma mark - Data loaders

- (BarChartData *)buildTimeDataFor:(BRApp *)app {
    NSMutableDictionary <NSString *, NSMutableDictionary<NSString *, NSNumber *> *> *flows = [@{} mutableCopy];
    [app.builds enumerateObjectsUsingBlock:^(BRBuild *build, BOOL *stop) {
        NSTimeInterval queuedTime = [build.startTime timeIntervalSinceDate:build.triggerTime];
        NSTimeInterval buildTime = [build.finishedTime timeIntervalSinceDate:build.startTime];
        
        if (flows[build.workflow]) {
            flows[build.workflow][@"q"] = @(flows[build.workflow][@"q"].doubleValue + queuedTime);
            flows[build.workflow][@"b"] = @(flows[build.workflow][@"b"].doubleValue + buildTime);
        } else {
            flows[build.workflow] = [@{ @"q" : @(queuedTime), @"b" : @(buildTime) } mutableCopy];
        }
    }];
    
    __block NSUInteger entryIndex = 0;
    __block NSMutableArray <BarChartDataEntry *> *entries = [NSMutableArray array];
    [flows enumerateKeysAndObjectsUsingBlock:^(NSString *flowName, NSMutableDictionary<NSString *,NSNumber *> *flowData, BOOL *stop) {
        BarChartDataEntry *entry = [[BarChartDataEntry alloc] initWithX:entryIndex
                                                                yValues:@[flowData[@"q"], flowData[@"b"]]];
        [entries addObject:entry];
        ++entryIndex;
    }];
    
    BarChartDataSet *dataSet = [[BarChartDataSet alloc] initWithEntries:entries label:@""];
    dataSet.stackLabels = @[@"queued", @"building"];
    dataSet.colors = @[[BRStyleSheet progressColor], [BRStyleSheet successColor]];
    
    BarChartData *chartData = [[BarChartData alloc] initWithDataSet:dataSet];
    
    return chartData;
}

- (BarChartData *)buildStatusDataFor:(BRApp *)app {
    NSMutableDictionary <NSString *, NSMutableDictionary<NSString *, NSNumber *> *> *flows = [@{} mutableCopy];
    [app.builds enumerateObjectsUsingBlock:^(BRBuild *build, BOOL *stop) {
        BRBuildStateInfo *buildStateInfo = [[[BRBuildInfo alloc] initWithBuild:build] stateInfo];
        if (flows[build.workflow]) {
            flows[build.workflow][@"s"] = @(flows[build.workflow][@"s"].integerValue + (buildStateInfo.state == BRBuildStateSuccess ? 1 : 0));
            flows[build.workflow][@"f"] = @(flows[build.workflow][@"f"].integerValue + (buildStateInfo.state == BRBuildStateFailed ? 1 : 0));
            flows[build.workflow][@"a"] = @(flows[build.workflow][@"a"].integerValue + (buildStateInfo.state == BRBuildStateAborted ? 1 : 0));
        } else {
            flows[build.workflow] = [@{ @"s" : @(buildStateInfo.state == BRBuildStateSuccess ? 1 : 0),
                                        @"f" : @(buildStateInfo.state == BRBuildStateFailed ? 1 : 0),
                                        @"a" : @(buildStateInfo.state == BRBuildStateAborted ? 1 : 0) } mutableCopy];
        }
    }];
    
    __block NSUInteger entryIndex = 0;
    __block NSMutableArray <BarChartDataEntry *> *entries = [NSMutableArray array];
    [flows enumerateKeysAndObjectsUsingBlock:^(NSString *flowName, NSMutableDictionary<NSString *,NSNumber *> *flowData, BOOL *stop) {
        BarChartDataEntry *entry = [[BarChartDataEntry alloc] initWithX:entryIndex
                                                                yValues:@[flowData[@"s"], flowData[@"f"], flowData[@"a"]]];
        [entries addObject:entry];
        ++entryIndex;
    }];
    
    BarChartDataSet *dataSet = [[BarChartDataSet alloc] initWithEntries:entries label:@""];
    dataSet.stackLabels = @[@"Success", @"Failed", @"Aborted"];
    dataSet.colors = @[[BRStyleSheet successColor], [BRStyleSheet failedColor], [BRStyleSheet abortedColor]];
    
    BarChartData *chartData = [[BarChartData alloc] initWithDataSet:dataSet];
    
    return chartData;
}

@end
