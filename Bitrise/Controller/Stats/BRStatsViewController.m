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
#import "BRChartValueFormatter.h"
#import "BRStatsInfoView.h"

@interface BRStatsViewController ()

@property (strong, nonatomic) BRAccountsObserver *accountObserver;
@property (strong, nonatomic) BRAppsObserver *appsObserver;
@property (strong, nonatomic) NSNotificationCenter *notificationCenter;

@property (weak) IBOutlet BRStatsInfoView *infoView1;
@property (weak) IBOutlet BRStatsInfoView *infoView2;
@property (weak) IBOutlet BRStatsInfoView *infoView3;
@property (weak) IBOutlet BRStatsInfoView *infoView4;

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
    [self loadInfoDataFor:app];
    
    self.chartView1.data = [self buildDailyDataFor:app];
    self.chartView5.data = [self buildMachineDataFor:app];
    self.chartView2.data = [self buildStatusDataFor:app];
    self.chartView4.data = [self buildTimeDataFor:app];
}

- (void)loadDataForAccount:(BTRAccount *)account {

}

- (void)loadCharts:(BarChartData *)chartData {
    self.chartView1.data = chartData;
    self.chartView2.data = chartData;
    self.chartView3.data = chartData;
    self.chartView4.data = chartData;
    self.chartView5.data = chartData;
}

#pragma mark - Info loaders -

- (void)loadInfoDataFor:(BRApp *)app {
    self.infoView1.label1.stringValue = @"Builds";
    self.infoView1.label2.stringValue = [NSString stringWithFormat:@"%lu", (unsigned long)app.builds.count];
    self.infoView1.label3.stringValue = @"";
    
    __block NSTimeInterval buildTime = 0;
    __block NSTimeInterval queuedTime = 0;
    __block NSUInteger successBuilds = 0;
    [app.builds enumerateObjectsUsingBlock:^(BRBuild *build, BOOL *stop) {
        if (build.finishedTime && build.startTime) {
            buildTime += [build.finishedTime timeIntervalSinceDate:build.startTime];
        }
        if (build.startTime && build.triggerTime) {
            queuedTime += [build.startTime timeIntervalSinceDate:build.triggerTime];
        }
        if (build.status.integerValue == 1) {
            successBuilds++;
        }
    }];
    
    self.infoView2.label1.stringValue = @"Build Time";
    self.infoView2.label2.stringValue = [NSString stringWithFormat:@"%f", buildTime];
    self.infoView2.label3.stringValue = @"Total build time";
    
    self.infoView3.label1.stringValue = @"Queued Time";
    self.infoView3.label2.stringValue = [NSString stringWithFormat:@"%f", queuedTime];
    self.infoView3.label3.stringValue = @"Total queued time";
    
    self.infoView4.label1.stringValue = @"Success Rate";
    self.infoView4.label2.stringValue = [NSString stringWithFormat:@"%.2f%%", ((double)successBuilds / (double)app.builds.count) * 100.0];
    self.infoView4.label3.stringValue = @"Percentage of successfull builds";
}

#pragma mark - Chart Data loaders -

#pragma mark - Dynamic

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

#pragma mark - Static

- (BarChartData *)buildDailyDataFor:(BRApp *)app {
    NSMutableDictionary <NSDate *, NSMutableArray<BarChartDataEntry *> *> *days = [@{} mutableCopy];
    __block NSUInteger entryIndex = 0;
    [app.builds enumerateObjectsUsingBlock:^(BRBuild *build, BOOL *stop) {
        NSTimeInterval queuedTime = [build.startTime timeIntervalSinceDate:build.triggerTime];
        NSTimeInterval buildTime = [build.finishedTime timeIntervalSinceDate:build.startTime];
        
        NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components: NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:build.triggerTime];
        NSDate *buildDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
        
        BarChartDataEntry *entry = [[BarChartDataEntry alloc] initWithX:build.triggerTime.timeIntervalSince1970 / (3600) yValues:@[@(queuedTime), @(buildTime)]];
        if (days[buildDate]) {
            [days[buildDate] addObject:entry];
        } else {
            days[buildDate] = [@[entry] mutableCopy];
        }
        ++entryIndex;
    }];
    
    __block NSMutableArray <BarChartDataSet *> *dataSets = [NSMutableArray array];
    [days enumerateKeysAndObjectsUsingBlock:^(NSDate *day, NSMutableArray<BarChartDataEntry *> *dayEntries, BOOL *stop) {
        BarChartDataSet *dataSet = [[BarChartDataSet alloc] initWithEntries:dayEntries label:@""];
        dataSet.colors = @[[BRStyleSheet progressColor], [BRStyleSheet successColor]];
//        dataSet.valueFormatter = [BRChartValueFormatter new];
        [dataSets addObject:dataSet];
    }];
    
    BarChartData *chartData = [[BarChartData alloc] initWithDataSets:dataSets];
    
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

- (BarChartData *)buildMachineDataFor:(BRApp *)app {
    NSMutableDictionary <NSString *, NSMutableDictionary<NSString *, NSNumber *> *> *machines = [@{} mutableCopy];
    [app.builds enumerateObjectsUsingBlock:^(BRBuild *build, BOOL *stop) {
        NSTimeInterval queuedTime = [build.startTime timeIntervalSinceDate:build.triggerTime];
        NSTimeInterval buildTime = [build.finishedTime timeIntervalSinceDate:build.startTime];
        NSString *machineID = build.machineTypeID ?: @"unknown";
        if (machines[machineID]) {
            machines[machineID][@"q"] = @(machines[machineID][@"q"].doubleValue + queuedTime);
            machines[machineID][@"b"] = @(machines[machineID][@"b"].doubleValue + buildTime);
        } else {
            machines[machineID] = [@{ @"q" : @(queuedTime), @"b" : @(buildTime) } mutableCopy];
        }
    }];
    
    __block NSUInteger entryIndex = 0;
    __block NSMutableArray <BarChartDataEntry *> *entries = [NSMutableArray array];
    [machines enumerateKeysAndObjectsUsingBlock:^(NSString *machineName, NSMutableDictionary<NSString *, NSNumber *> *machineData, BOOL *stop) {
        BarChartDataEntry *entry = [[BarChartDataEntry alloc] initWithX:entryIndex
                                                                yValues:@[machineData[@"q"], machineData[@"b"]]];
        [entries addObject:entry];
        ++entryIndex;
    }];
    
    BarChartDataSet *dataSet = [[BarChartDataSet alloc] initWithEntries:entries label:@""];
    dataSet.stackLabels = @[@"queued", @"building"];
    dataSet.colors = @[[BRStyleSheet progressColor], [BRStyleSheet successColor]];
    
    BarChartData *chartData = [[BarChartData alloc] initWithDataSet:dataSet];
    
    return chartData;
}


@end
