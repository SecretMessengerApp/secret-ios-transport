// 
// 


@import XCTest;
#import "ZMTemporaryFileListForBackgroundRequests.h"

@interface ZMTemporaryFileListForBackgroundRequestTests : XCTestCase

@property (nonatomic) ZMTemporaryFileListForBackgroundRequests *sut;

@end

@implementation ZMTemporaryFileListForBackgroundRequestTests

- (void)setUp {
    [super setUp];

    self.sut = [[ZMTemporaryFileListForBackgroundRequests alloc] init];

}

- (void)tearDown {
    
    self.sut = nil;
    [super tearDown];
}

- (void)testThatItCreatesAFileForATask
{
    // given
    NSData *originalData = [@"This is a test" dataUsingEncoding:NSUTF8StringEncoding];
    
    // when
    NSURL *file = [self.sut temporaryFileWithBodyData:originalData];
    
    // then
    XCTAssertNotNil(file);
    NSData *readData = [NSData dataWithContentsOfFile:file.path];
    XCTAssertEqualObjects(originalData, readData);
    
    // after
    [[NSFileManager defaultManager] removeItemAtURL:file error:NULL];
}

- (void)testThatItCreatesDifferentFilesForDifferentTasks
{
    // given
    NSData *originalData1 = [@"This is a test" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *originalData2 = [@"This is also a test" dataUsingEncoding:NSUTF8StringEncoding];
    
    // when
    NSURL *file1 = [self.sut temporaryFileWithBodyData:originalData1];
    NSURL *file2 = [self.sut temporaryFileWithBodyData:originalData2];
    
    // then
    XCTAssertNotNil(file1);
    XCTAssertNotNil(file2);
    
    NSData *readData1 = [NSData dataWithContentsOfFile:file1.path];
    NSData *readData2 = [NSData dataWithContentsOfFile:file2.path];

    XCTAssertEqualObjects(originalData1, readData1);
    XCTAssertEqualObjects(originalData2, readData2);
    
    // after
    [[NSFileManager defaultManager] removeItemAtURL:file1 error:NULL];
    [[NSFileManager defaultManager] removeItemAtURL:file2 error:NULL];
}

- (void)testThatItDeletesAFileForATask
{
    // given
    NSUInteger taskID = 32;
    NSData *originalData = [@"This is a test" dataUsingEncoding:NSUTF8StringEncoding];
    
    // when
    NSURL *file = [self.sut temporaryFileWithBodyData:originalData];
    [self.sut setTemporaryFile:file forTaskIdentifier:taskID];
    [self.sut deleteFileForTaskID:taskID];
    
    // then
    XCTAssertNotNil(file);
    NSData *readData = [NSData dataWithContentsOfFile:file.path];
    XCTAssertNil(readData);
}

@end
