//
//  BRLogsTextViewController.m
//  Bitrise
//
//  Created by Deszip on 18/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRLogsTextViewController.h"

#import "BRProgressObserver.h"

static void *BRLogsTextViewControllerContext = &BRLogsTextViewControllerContext;

@interface BRLogsTextViewController ()

@property (strong, nonatomic) BRLogsDataSource *logDataSource;
@property (strong, nonatomic) BRLogObserver *logObserver;
@property (strong, nonatomic) NSProgress *loadingProgress;

@property (strong, nonatomic) BRProgressObserver *progressObserver;

@property (unsafe_unretained) IBOutlet NSTextView *logTextView;
@property (weak) IBOutlet NSProgressIndicator *loadingProgressIndicator;

@end

@implementation BRLogsTextViewController

- (void)dealloc {
    [self.progressObserver stop];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAppearance];
}

#pragma mark - Setup -

- (void)setBuildInfo:(BRBuildInfo *)buildInfo {
    _buildInfo = buildInfo;
    self.view.window.title = [NSString stringWithFormat:@"%@: %@", self.buildInfo.appName, self.buildInfo.branchName];
    
    // Observer
    self.logObserver = [self.dependencyContainer logObserver];
    __weak typeof(self) weakSelf = self;
    [self.logObserver loadLogsForBuild:self.buildInfo.slug callback:^(BRLogLoadingState state, NSProgress *progress) {
        [weakSelf handleState:state withProgress:progress];
    }];
    
    // Data source
    self.logDataSource = [self.dependencyContainer logDataSource];
    [self.logDataSource bindTextView:self.logTextView];
    [self.logDataSource fetch:self.buildInfo.slug];
}

- (void)handleState:(BRLogLoadingState)state withProgress:(NSProgress *)progress {
    switch (state) {
        case BRLogLoadingStateStarted: [self showProgress]; break;
        case BRLogLoadingStateFinished: [self hideProgress]; break;
            
        case BRLogLoadingStateInProgress:
            if (progress) {
                self.progressObserver = [BRProgressObserver new];
                [self.progressObserver bindProgress:progress toIndicator:self.loadingProgressIndicator];
            }
            break;
            
        case BRLogLoadingStateUndefined: break;
    }
}

#pragma mark - Appearance -

- (void)setupAppearance {
    [self.logTextView setFont:[NSFont fontWithName:@"Menlo" size:12.0]];
}

- (void)showProgress {
    self.loadingProgressIndicator.hidden = NO;
}

- (void)hideProgress {
    self.loadingProgressIndicator.hidden = YES;
}

@end
