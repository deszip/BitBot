//
//  BRaboutViewController.m
//  Bitrise
//
//  Created by Deszip on 06/01/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRaboutViewController.h"

#import "BRAboutTextView.h"

@interface BRaboutViewController ()

@property (weak) IBOutlet NSTextField *versionField;
@property (unsafe_unretained) IBOutlet BRAboutTextView *aboutTextView;

@end

@implementation BRaboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.aboutTextView setAutomaticLinkDetectionEnabled:YES];
}

@end
