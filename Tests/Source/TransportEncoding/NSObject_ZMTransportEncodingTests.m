// 
// 


@import WireTransport;
@import XCTest;

@interface NSObjectZMTransportEncodingTests : XCTestCase
@end

@interface NSObjectZMTransportEncodingTests (NSDate)
@end
@interface NSObjectZMTransportEncodingTests (NSUUID)
@end

@implementation NSObjectZMTransportEncodingTests
@end







@implementation NSObjectZMTransportEncodingTests (NSDate)

- (void)testThatItCanParseTransportDates;
{
    XCTAssertEqualWithAccuracy([NSDate dateWithTransportString:@"2014-03-14T16:47:37.573Z"].timeIntervalSinceReferenceDate, 416508457.573, 0.0006);
    XCTAssertEqualWithAccuracy([NSDate dateWithTransportString:@"2014-04-15T08:45:04.502Z"].timeIntervalSinceReferenceDate, 419244304.502, 0.0006);
}

- (void)testThatItReturnsNilWhenTheDateIsInvalid;
{
    XCTAssertNil([NSDate dateWithTransportString:@"2014-03-14T16:37.573Z"]);
    XCTAssertNil([NSDate dateWithTransportString:@"2014-03-14 16:47:37.573Z"]);
    XCTAssertNil([NSDate dateWithTransportString:@"2014-03T16:47:37.573Z"]);
}

- (void)testThatItCanOutputTransportEncoding;
{
    XCTAssertEqualObjects([[NSDate dateWithTimeIntervalSinceReferenceDate:416508457.573] transportString], @"2014-03-14T16:47:37.573Z");
    XCTAssertEqualObjects([[NSDate dateWithTimeIntervalSinceReferenceDate:419244304.502] transportString], @"2014-04-15T08:45:04.502Z");
}


@end






@implementation NSObjectZMTransportEncodingTests (NSUUID)

- (void)testThatItCanParseUppercaseUUID
{
    // given
    NSString *string = @"E3F77380-A03E-45BB-A598-D361E3220001";
    NSUUID *expected = [[NSUUID alloc] initWithUUIDString:@"E3F77380-A03E-45BB-A598-D361E3220001"];
    
    // when
    NSUUID *sut = [NSUUID uuidWithTransportString:string];
    
    // then
    XCTAssertNotNil(sut);
    XCTAssertEqualObjects(sut, expected);
}


- (void)testThatItCanParseLowercaseUUID
{
    // given
    NSString *string = [@"E3F77380-A03E-45BB-A598-D361E3220001" lowercaseString];
    NSUUID *expected = [[NSUUID alloc] initWithUUIDString:@"E3F77380-A03E-45BB-A598-D361E3220001"];
    
    // when
    NSUUID *sut = [NSUUID uuidWithTransportString:string];
    
    // then
    XCTAssertNotNil(sut);
    XCTAssertEqualObjects(sut, expected);
}


- (void)testThatTheTransportStringIsAlwaysLowercase
{
    // given
    NSString *string = @"E3F77380-A03E-45BB-A598-D361E3220001";
    NSUUID *sut = [NSUUID uuidWithTransportString:string];
    
    // when
    NSString *transportString = [sut transportString];
    
    // then
    NSString *expectedString = [string lowercaseString];
    XCTAssertEqualObjects(expectedString, transportString);
}


@end

