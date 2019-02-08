//
//  BRLogsViewController.m
//  Bitrise
//
//  Created by Deszip on 02/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRLogsViewController.h"

@interface BRLogsViewController ()

@property (strong, nonatomic) BRLogObserver *logObserver;

@end

@implementation BRLogsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setBuildSlug:(NSString *)buildSlug {
    _buildSlug = buildSlug;
    
    // Build a logs datasource
}

@end
