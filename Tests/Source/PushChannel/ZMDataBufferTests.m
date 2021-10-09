// 
// 


@import WireTesting;
@import WireUtilities;
@import WireTransport;

@interface ZMDataBufferTests : XCTestCase

@property (nonatomic) DataBuffer *sut;

@end

@implementation ZMDataBufferTests

- (void)setUp {
    self.sut = [[DataBuffer alloc] init];
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
    self.sut = nil;
}

- (void)testThatItStartsEmpty
{
    XCTAssertNotNil(self.sut.objcData);
    XCTAssertEqual(dispatch_data_get_size(self.sut.objcData), 0u);
}

- (void)testThatItAppendsDataFromEmpty
{
    // given
    dispatch_data_t data = [@"test foo bar" dataUsingEncoding:NSUTF8StringEncoding].dispatchData;
    
    // when
    [self.sut appendData:data];
    dispatch_data_t bufferData = self.sut.objcData;
    
    // then
    XCTAssertEqualObjects(data, bufferData);
}

- (void)testThatItAppendsDataWithPreviousData
{
    // given
    dispatch_data_t data1 = [@"111" dataUsingEncoding:NSUTF8StringEncoding].dispatchData;
    dispatch_data_t data2 = [@"222" dataUsingEncoding:NSUTF8StringEncoding].dispatchData;
    dispatch_data_t expectedData = [@"111222" dataUsingEncoding:NSUTF8StringEncoding].dispatchData;
    
    [self.sut appendData:data1];
    
    // when
    [self.sut appendData:data2];
    dispatch_data_t bufferData = self.sut.objcData;
    
    // then
    XCTAssertEqualObjects(expectedData, bufferData);
    
}

- (void)testThatItClearsUntilOffset
{
    // given
    dispatch_data_t data1 = [@"aaaabbcc" dataUsingEncoding:NSUTF8StringEncoding].dispatchData;
    dispatch_data_t expectedData = [@"cc" dataUsingEncoding:NSUTF8StringEncoding].dispatchData;
    
    [self.sut appendData:data1];
    
    // when
    [self.sut clearUntil:4];
    [self.sut clearUntil:2];
    dispatch_data_t bufferData = self.sut.objcData;
    
    // then
    XCTAssertEqualObjects(expectedData, bufferData);
}


@end
