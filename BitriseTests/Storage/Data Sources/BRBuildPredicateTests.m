//
//  BRBuildPredicateTests.m
//  BitBotTests
//
//  Created by Deszip on 15.10.2022.
//  Copyright © 2022 Bitrise. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "Expecta/Expecta.h"

#import "BRBuildPredicate.h"

@interface BRBuildPredicateTests : XCTestCase

@end

@implementation BRBuildPredicateTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testPredicateInitiallyEmpty {
    BRBuildPredicate *predicate = [BRBuildPredicate new];
    
    expect(predicate.hasConditions).to.beFalsy();
    expect(predicate.predicate).to.beFalsy();
}

- (void)testClearDropsConditions {
    BRBuildPredicate *predicate = [BRBuildPredicate new];
    BRFilterCondition *condition = [[BRFilterCondition alloc] initWithAppSlug:@"DEADBEEF"];
    
    [predicate toggleCondition:condition];
    expect(predicate.hasConditions).to.beTruthy();
    
    [predicate clear];
    expect(predicate.hasConditions).to.beFalsy();
}

- (void)testPredicateTogglesCondition {
    BRBuildPredicate *predicate = [BRBuildPredicate new];
    BRFilterCondition *condition = [[BRFilterCondition alloc] initWithAppSlug:@"DEADBEEF"];
    
    [predicate toggleCondition:condition];
    expect(predicate.hasConditions).to.beTruthy();
    
    [predicate toggleCondition:condition];
    expect(predicate.hasConditions).to.beFalsy();
}

@end
