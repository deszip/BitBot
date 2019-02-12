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
@property (unsafe_unretained) IBOutlet NSTextView *logTextView;
@property (weak) IBOutlet NSOutlineView *logOutline;

@end

@implementation BRLogsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.logTextView setFont:[NSFont fontWithName:@"Menlo" size:12.0]];
}

- (void)setBuildSlug:(NSString *)buildSlug {
    _buildSlug = buildSlug;
    
    self.logObserver = [self.dependencyContainer logObserver];
    [self.logObserver loadLogsForBuild:self.buildSlug];
    
    self.logDataSource = [self.dependencyContainer logDataSource];
    
//    __weak __typeof(self) weakSelf = self;
//    [self.logDataSource setUpdateCallback:^(NSString *log) {
//        NSLog(@"BRLogsViewController: update callback, text length: %ld", log.length);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            weakSelf.logTextView.string = log;
//            if (weakSelf.logTextView.selectedRanges.count == 0) {
//                [weakSelf.logTextView scrollToEndOfDocument:weakSelf];
//            }
//        });
//    }];
//
//    [self.logDataSource setInsertCallback:^(NSString *log) {
//        NSLog(@"BRLogsViewController: insert callback, text length: %ld", log.length);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [weakSelf.logTextView insertText:log replacementRange:NSMakeRange(weakSelf.logTextView.string.length-1, 0)];
//            if (weakSelf.logTextView.selectedRanges.count == 0) {
//                [weakSelf.logTextView scrollToEndOfDocument:weakSelf];
//            }
//        });
//    }];

    
    [self.logDataSource bind:self.logOutline];
    [self.logDataSource fetch:self.buildSlug];
}

@end
