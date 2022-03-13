//
//  BitBotMenuUITestsLaunchTests.m
//  BitBotMenuUITests
//
//  Created by Deszip on 13.03.2022.
//  Copyright © 2022 Bitrise. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface BitBotMenuUITestsLaunchTests : XCTestCase

@end

@implementation BitBotMenuUITestsLaunchTests

+ (BOOL)runsForEachTargetApplicationUIConfiguration {
    return YES;
}

- (void)setUp {
    self.continueAfterFailure = NO;
}

- (void)testLaunch {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app launch];

    // Insert steps here to perform after app launch but before taking a screenshot,
    // such as logging into a test account or navigating somewhere in the app

    XCTAttachment *attachment = [XCTAttachment attachmentWithScreenshot:XCUIScreen.mainScreen.screenshot];
    attachment.name = @"Launch Screen";
    attachment.lifetime = XCTAttachmentLifetimeKeepAlways;
    [self addAttachment:attachment];
}

@end
