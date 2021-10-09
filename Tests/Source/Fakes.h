// 
// 


@import WireTransport;

#pragma mark - FakeURLResponse


@class FakeURLResponse;
@interface FakeDataTask : NSObject

@property (nonatomic) NSError *fakeError;
@property (nonatomic) NSUInteger fakeTaskIdentifier;
@property (nonatomic) FakeURLResponse *fakeURLResponse;

- (instancetype)initWithError:(NSError *)error taskIdentifier:(NSUInteger)taskIdentifier response:(FakeURLResponse *)response;
- (void)resume;
- (NSURLResponse *)response;
- (NSError *)error;
- (NSURLRequest *)originalRequest;

@end


#pragma mark - FakeURLResponse


@interface FakeURLResponse : NSObject

+ (instancetype)testResponse;

@property (nonatomic) NSData *body;
@property (nonatomic) NSInteger statusCode;
@property (nonatomic) NSDictionary *allHeaderFields;
@property (nonatomic) NSError *error;

- (void)setBodyFromTransportData:(id<ZMTransportData>)data;
@end


#pragma mark - FakeTransportResponse


@interface FakeTransportResponse : NSObject
+ (instancetype)testResponse;
@property (nonatomic) NSInteger HTTPStatus;
@property (nonatomic) ZMTransportResponseStatus result;
@property (nonatomic) NSDictionary *payload;
@end


#pragma mark - FakeExponentialBackoff


@interface FakeExponentialBackoff : NSObject
@property (nonatomic) NSMutableArray *blocks;
@property (nonatomic) NSInteger resetBackoffCount;
@property (nonatomic) NSInteger increaseBackoffCount;
@end


#pragma mark - FakeDelegate


@interface FakeDelegate : NSObject <ZMAccessTokenHandlerDelegate>
@property (nonatomic) NSUInteger delegateCallCount;
@property (nonatomic, copy) dispatch_block_t didReceiveAccessTokenBlock;
@end

#pragma mark - ZMSGroupQueue

@interface FakeGroupQueue : NSObject <ZMSGroupQueue>

@end
