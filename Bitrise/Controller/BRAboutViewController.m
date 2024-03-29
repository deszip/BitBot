//
//  BRaboutViewController.m
//  Bitrise
//
//  Created by Deszip on 06/01/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRAboutViewController.h"

#import "BRDisableableScrollView.h"
#import "BRAboutTextView.h"
#import "BRStyleSheet.h"

@interface BRAboutViewController ()

@property (weak) IBOutlet BRDisableableScrollView *scrollView;
@property (weak) IBOutlet NSTextField *nameField;
@property (weak) IBOutlet NSTextField *versionField;
@property (weak) IBOutlet BRAboutTextView *aboutTextView;

@end

@implementation BRAboutViewController

@synthesize dependencyContainer;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView.scrollingEnabled = NO;
    
    [self.nameField setFont:[BRStyleSheet aboutTitleFont]];
    [self.versionField setFont:[BRStyleSheet aboutVersionFont]];
    
    [self.aboutTextView setAutomaticLinkDetectionEnabled:YES];
    [self.aboutTextView setFont:[BRStyleSheet aboutTextFont]];
    
    [self.aboutTextView setTextColor:[BRStyleSheet textColor]];
    [self.nameField setTextColor:[BRStyleSheet textColor]];
    [self.versionField setTextColor:[BRStyleSheet textColor]];
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
