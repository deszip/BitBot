//
//  BRLogsViewController.m
//  Bitrise
//
//  Created by Deszip on 02/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRLogsViewController.h"

#import "BRStyleSheet.h"

@interface BRLogsViewController ()

@property (strong, nonatomic) BRLogsDataSource *logDataSource;
@property (strong, nonatomic) BRLogObserver *logObserver;
@property (unsafe_unretained) IBOutlet NSTextView *logTextView;
@property (weak) IBOutlet NSOutlineView *logOutline;

@end

@implementation BRLogsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.logTextView setFont:[NSFont fontWithName:@"Menlo" size:12.0]];
    [self.logTextView setBackgroundColor:[BRStyleSheet backgroundColor]];
}

- (void)setBuildSlug:(NSString *)buildSlug {
    _buildSlug = buildSlug;
    
    self.logObserver = [self.dependencyContainer logObserver];
    [self.logObserver loadLogsForBuild:self.buildSlug callback:nil];
    
    self.logDataSource = [self.dependencyContainer logDataSource];
    
    [self.logDataSource bindTextView:self.logTextView];
    [self.logDataSource fetch:self.buildSlug];
}

@end
