// 
// 


@import WireTesting;
@import XCTest;

#import "ZMKeychain.h"

@interface ZMKeychainTests : XCTestCase

@end

@implementation ZMKeychainTests

#if TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR

- (void)testThatItOnlyDeletesItemsOfSpecificAccount
{
    // given
    NSString *accountA = @"foo";
    NSString *accountB = @"bar";
    
    [ZMKeychain setData:[NSData data] forAccount:accountA];
    [ZMKeychain setData:[NSData data] forAccount:accountB];

    XCTAssertNotNil([ZMKeychain dataForAccount:accountA]);
    XCTAssertNotNil([ZMKeychain dataForAccount:accountB]);

    // when
    [ZMKeychain deleteAllKeychainItemsWithAccountName:accountA];
    
    // then
    XCTAssertNil([ZMKeychain dataForAccount:accountA]);
    XCTAssertNotNil([ZMKeychain dataForAccount:accountB]);
    
}


- (void)testThatItDeletesAllItemsOfAllAccounts
{
    // given
    NSString *accountA = @"foo";
    NSString *accountB = @"bar";
    
    [ZMKeychain setData:[NSData data] forAccount:accountA];
    [ZMKeychain setData:[NSData data] forAccount:accountB];
    
    XCTAssertNotNil([ZMKeychain dataForAccount:accountA]);
    XCTAssertNotNil([ZMKeychain dataForAccount:accountB]);
    
    // when
    [ZMKeychain deleteAllKeychainItems];
    
    // then
    XCTAssertNil([ZMKeychain dataForAccount:accountA]);
    XCTAssertNil([ZMKeychain dataForAccount:accountB]);
    
}
#endif

@end
