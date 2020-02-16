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

- (void)testParserDetectsBrokenLine {
    expect([self.parser lineBroken:@"foo"]).to.beTruthy();
}

- (void)testParserDetectsLineWithNewline {
    expect([self.parser lineBroken:@"foo\n"]).to.beFalsy();
}

- (void)testParserDetectsEmtyLineAsNonBroken {
    expect([self.parser lineBroken:@""]).to.beFalsy();
}

- (void)testSplittingChunk {
    NSString *logChunk = @"line1\nline2\nline3";
    NSArray *chunks = [self.parser split:logChunk];
    
    expect(chunks.count).to.equal(3);
}

- (void)testSplittingChunkWithNewlineAtTheEnd {
    NSString *logChunk = @"line1\nline2\nline3\n";
    NSArray *chunks = [self.parser split:logChunk];
    
    expect(chunks.count).to.equal(3);
}

- (void)testSplittingEmptyChunk {
    NSString *logChunk = @"";
    NSArray *chunks = [self.parser split:logChunk];
    
    expect(chunks.count).to.equal(0);
}

- (void)testColorSplit {
    NSString *line = @"[36mINFO[0m[08:59:14] [33;1mbitrise runs in Secret Filtering mode[0m";
    NSAttributedString *coloredString = [self.parser coloredLine:line];
    
    expect(coloredString).toNot.beNil();
}

@end
