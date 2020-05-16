//
//  BRaboutViewController.m
//  Bitrise
//
//  Created by Deszip on 06/01/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRAboutViewController.h"

#import "BRAboutTextView.h"
#import "BRStyleSheet.h"

@interface BRAboutViewController ()

@property (weak) IBOutlet NSTextField *versionField;
@property (unsafe_unretained) IBOutlet BRAboutTextView *aboutTextView;

@end

@implementation BRAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.aboutTextView setAutomaticLinkDetectionEnabled:YES];
    [self.aboutTextView setFont:[BRStyleSheet proximaNova:15.0]];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    
    [self updateVersion];
}

- (void)updateVersion {
    NSString *version = [[self.dependencyContainer appEnvironment] versionNumber];
    NSString *build = [[self.dependencyContainer appEnvironment] buildNumber];
    [self.versionField setStringValue:[NSString stringWithFormat:@"version %@ (%@)", version, build]];
}

@end
