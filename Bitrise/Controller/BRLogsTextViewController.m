//
//  BRLogsTextViewController.m
//  Bitrise
//
//  Created by Deszip on 18/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRLogsTextViewController.h"

static void *BRLogsTextViewControllerContext = &BRLogsTextViewControllerContext;

@interface BRLogsTextViewController ()

@property (strong, nonatomic) BRLogsDataSource *logDataSource;
@property (strong, nonatomic) BRLogObserver *logObserver;
@property (strong, nonatomic) NSProgress *loadingProgress;

@property (unsafe_unretained) IBOutlet NSTextView *logTextView;
@property (weak) IBOutlet NSProgressIndicator *loadingProgressIndicator;

@end

@implementation BRLogsTextViewController

- (void)dealloc {
    [self.loadingProgress removeObserver:self forKeyPath:@"fractionCompleted" context:BRLogsTextViewControllerContext];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.logTextView setFont:[NSFont fontWithName:@"Menlo" size:12.0]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == BRLogsTextViewControllerContext) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([keyPath isEqualToString:@"fractionCompleted"]) {
                self.loadingProgressIndicator.doubleValue = [(NSProgress *)object fractionCompleted];
            }
        });
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)setBuildSlug:(NSString *)buildSlug {
    _buildSlug = buildSlug;
    
    self.logObserver = [self.dependencyContainer logObserver];
    __weak typeof(self) weakSelf = self;
    [self.logObserver loadLogsForBuild:self.buildSlug callback:^(BRLogLoadingState state, NSProgress *progress) {
        switch (state) {
            case BRLogLoadingStateStarted:
                weakSelf.loadingProgressIndicator.hidden = NO;
                break;
                
            case BRLogLoadingStateInProgress:
                if (progress) {
                    weakSelf.loadingProgress = progress;
                    [weakSelf.loadingProgress addObserver:weakSelf forKeyPath:@"fractionCompleted" options:0 context:BRLogsTextViewControllerContext];
                }
                break;
                
            case BRLogLoadingStateFinished:
                weakSelf.loadingProgressIndicator.hidden = YES;
                break;
                
            case BRLogLoadingStateUndefined: break;
        }
    }];
    
    self.logDataSource = [self.dependencyContainer logDataSource];
    [self.logDataSource bindTextView:self.logTextView];
    [self.logDataSource fetch:self.buildSlug];
}

@end
