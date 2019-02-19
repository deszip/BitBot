//
//  BRLogsTextViewController.m
//  Bitrise
//
//  Created by Deszip on 18/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRLogsTextViewController.h"

@interface BRLogsTextViewController ()

@property (strong, nonatomic) BRLogsDataSource *logDataSource;
@property (strong, nonatomic) BRLogObserver *logObserver;
@property (unsafe_unretained) IBOutlet NSTextView *logTextView;

@end

@implementation BRLogsTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.logTextView setFont:[NSFont fontWithName:@"Menlo" size:12.0]];
}

- (void)setBuildSlug:(NSString *)buildSlug {
    _buildSlug = buildSlug;
    
    self.logObserver = [self.dependencyContainer logObserver];
    [self.logObserver loadLogsForBuild:self.buildSlug];
    
    self.logDataSource = [self.dependencyContainer logDataSource];
    [self.logDataSource bindTextView:self.logTextView];
    [self.logDataSource fetch:self.buildSlug];
    
    NSLog(@"Controller: %@, observer: %@", self, self.logObserver);
}


@end
