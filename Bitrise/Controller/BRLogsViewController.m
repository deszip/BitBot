//
//  BRLogsViewController.m
//  Bitrise
//
//  Created by Deszip on 02/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRLogsViewController.h"

@interface BRLogsViewController ()

@property (strong, nonatomic) BRLogsDataSource *logDataSource;
@property (strong, nonatomic) BRLogObserver *logObserver;
@property (weak) IBOutlet NSTextField *logTextField;
@property (unsafe_unretained) IBOutlet NSTextView *logTextView;

@end

@implementation BRLogsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setBuildSlug:(NSString *)buildSlug {
    _buildSlug = buildSlug;
    
    self.logObserver = [self.dependencyContainer logObserver];
    [self.logObserver loadLogsForBuild:self.buildSlug];
    
    self.logDataSource = [self.dependencyContainer logDataSource];
    __weak __typeof(self) weakSelf = self;
    [self.logDataSource setUpdateCallback:^(NSString *log) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.logTextView.string = log;
        });
    }];
    [self.logDataSource fetch:self.buildSlug];
}

@end
