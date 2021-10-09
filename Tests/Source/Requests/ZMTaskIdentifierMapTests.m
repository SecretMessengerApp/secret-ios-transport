// 
// 


@import XCTest;
@import WireSystem;
#import "ZMTaskIdentifierMap.h"



@interface ZMTaskIdentifierMapTests : XCTestCase

@property (nonatomic) ZMTaskIdentifierMap *sut;

@end



@implementation ZMTaskIdentifierMapTests

- (void)setUp
{
    [super setUp];
    self.sut = [[ZMTaskIdentifierMap alloc] init];
}

- (void)tearDown
{
    self.sut = nil;
    [super tearDown];
}

- (void)testThatItIsEmptyWhenCreated;
{
    XCTAssertEqual(self.sut.count, 0u);
}

- (void)testThatItCanStoreObjects;
{
    // when
    self.sut[1] = @"A";
    self.sut[2] = @"B";
    
    // then
    XCTAssertEqualObjects(self.sut[1], @"A");
    XCTAssertEqualObjects(self.sut[2], @"B");
    XCTAssertEqual(self.sut.count, 2u);
}

- (void)testThatItCanReplaceObjects;
{
    // when
    self.sut[0] = @"A";
    self.sut[0] = @"B";
    
    // then
    XCTAssertEqualObjects(self.sut[0], @"B");
    XCTAssertEqual(self.sut.count, 1u);
}

- (void)testThatItCanDeleteObjects;
{
    // when
    self.sut[1] = @"A";
    [self.sut removeObjectForTaskIdentifier:1];
    
    // then
    XCTAssertNil(self.sut[1]);
}

- (void)testThatItCanEnumerateObjects;
{
    // given
    self.sut[11] = @"A";
    self.sut[22] = @"B";
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    __block int count = 0;
    
    // when
    [self.sut enumerateKeysAndObjectsUsingBlock:^(NSUInteger taskIdentifier, id obj, BOOL *stop) {
        NOT_USED(stop);
        ++count;
        dictionary[@(taskIdentifier)] = obj;
    }];
    
    // then
    XCTAssertEqual(count, 2);
    NSDictionary *expected = @{@11: @"A", @22: @"B"};
    XCTAssertEqualObjects(dictionary, expected);
}

@end
