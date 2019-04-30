//
//  BRLogsParserTests.m
//  BitriseTests
//
//  Created by Deszip on 14/03/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "Expecta/Expecta.h"

#import "BRLogsParser.h"

@interface BRLogsParserTests : XCTestCase

@property (strong, nonatomic) BRLogsParser *parser;

@end

@implementation BRLogsParserTests

- (void)setUp {
    self.parser = [BRLogsParser new];
}

- (void)tearDown {
    self.parser = nil;
}

- (void)testParserFindsStep {
    expect([self.parser stepNameForLine:@"| (5) slack    |"]).to.equal(@"slack");
}

- (void)testParserFindsTwoWordStep {
    expect([self.parser stepNameForLine:@"| (5) slack step    |"]).to.equal(@"slack step");
}

- (void)testParserFindsStepWithTwoSymbolIndex {
    expect([self.parser stepNameForLine:@"| (15) slack step    |"]).to.equal(@"slack step");
}

- (void)testParserReturnsNilIfNoStep {
    expect([self.parser stepNameForLine:@"foo"]).to.beNil();
}

@end
