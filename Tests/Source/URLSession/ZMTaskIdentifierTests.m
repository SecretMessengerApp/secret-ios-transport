// 
// 



@import WireTesting;
@import OCMock;
#import "ZMTaskIdentifier.h"


@interface ZMTaskIdentifierTests : ZMTBaseTest
@end


@implementation ZMTaskIdentifierTests

- (void)testThatItCreatesAnIdentifier {
    // given
    ZMTaskIdentifier *sut = [ZMTaskIdentifier identifierWithIdentifier:46 sessionIdentifier:@"foreground-session"];
    
    // then
    XCTAssertEqual(sut.identifier, 46lu);
    XCTAssertEqual(sut.sessionIdentifier, @"foreground-session");
}

- (void)testThatTwoEqualTaskIdentifierObjectsAreConsideredEqual {
    // given
    ZMTaskIdentifier *first = [ZMTaskIdentifier identifierWithIdentifier:46 sessionIdentifier:@"foreground-session"];
    ZMTaskIdentifier *second = [ZMTaskIdentifier identifierWithIdentifier:46 sessionIdentifier:@"foreground-session"];
    
    // then
    XCTAssertEqualObjects(first, second);
}

- (void)testThatTwoDifferentTaskIdentifierObjectsAreNotConsideredEqual {
    // given
    ZMTaskIdentifier *first = [ZMTaskIdentifier identifierWithIdentifier:46 sessionIdentifier:@"foreground-session"];
    ZMTaskIdentifier *second = [ZMTaskIdentifier identifierWithIdentifier:46 sessionIdentifier:@"background-session"];
    ZMTaskIdentifier *third = [ZMTaskIdentifier identifierWithIdentifier:12 sessionIdentifier:@"foreground-session"];
    
    // then
    XCTAssertNotEqualObjects(first, second);
    XCTAssertNotEqualObjects(first, third);
    XCTAssertNotEqualObjects(second, third);
}

- (void)testThatItCanBeSerializedAndDeserializedFromAndToNSData {
    // given
    ZMTaskIdentifier *sut = [ZMTaskIdentifier identifierWithIdentifier:46 sessionIdentifier:@"foreground-session"];
    XCTAssertNotNil(sut);
    
    // when
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:sut];
    XCTAssertNotNil(data);
    
    // then
    ZMTaskIdentifier *deserializedSut = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    XCTAssertNotNil(deserializedSut);
    XCTAssertEqualObjects(deserializedSut, sut);
}

- (void)testThatItCanBeInitializedFromDataAndReturnsTheCorrectData {
    // given
    ZMTaskIdentifier *sut = [ZMTaskIdentifier identifierWithIdentifier:42 sessionIdentifier:@"foreground-session"];
    XCTAssertNotNil(sut);
    
    // when
    NSData *data = sut.data;
    XCTAssertNotNil(data);
    
    // then
    ZMTaskIdentifier *deserializedSut = [ZMTaskIdentifier identifierFromData:data];
    XCTAssertNotNil(deserializedSut);
    XCTAssertEqualObjects(deserializedSut, sut);
}

@end
