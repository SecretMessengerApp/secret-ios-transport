// 
// 


#import "Fakes.h"


@implementation FakeDataTask

- (instancetype)initWithError:(NSError *)error taskIdentifier:(NSUInteger)taskIdentifier response:(FakeURLResponse *)response
{
    self = [super init];
    if(self) {
        self.fakeError = error;
        self.fakeTaskIdentifier = taskIdentifier;
        self.fakeURLResponse = response;
    }
    return self;
}

- (NSError *)error
{
    return self.fakeError;
}

- (NSUInteger)taskIdentifier
{
    return self.fakeTaskIdentifier;
}

- (NSURLResponse *)response
{
    return (NSURLResponse *)self.fakeURLResponse;
}

- (void)resume
{
}

- (NSURLRequest *)originalRequest
{
    return nil;
}

@end


@implementation FakeURLResponse

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.body = [NSData data];
        self.allHeaderFields = @{@"Content-Type": @"application/json"};
        self.error = nil;
    }
    
    return self;
}

+ (instancetype)testResponse
{
    return [[self alloc] init];
}

- (void)setBodyFromTransportData:(id<ZMTransportData>)object;
{
    if (object == nil) {
        self.body = nil;
    } else {
        NSError *error = nil;
        self.body = [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
        RequireString(self.body != nil, "Failed to serialize JSON: %lu", (long) error.code);
    }
}

- (void)setError:(NSError *)error;
{
    CheckString(error == nil || [error.domain isEqualToString:NSURLErrorDomain],
                "At this API level errors are supposed to be 'NSURLErrorDomain'.");
    _error = error;
}

- (ZMTransportResponseContentType)zmContentTypeForBodyData:(NSData *)bodyData;
{
    (void)bodyData;
    return ZMTransportResponseContentTypeJSON;
}

@end




@implementation FakeTransportResponse

+ (instancetype)testResponse
{
    return [[self alloc] init];
}

@end


@implementation FakeExponentialBackoff

- (instancetype)init;
{
    self = [super init];
    if (self) {
        self.blocks = [NSMutableArray array];
    }
    return self;
}

- (void)performBlock:(dispatch_block_t)block;
{
    [self.blocks addObject:[block copy]];
}

- (void)resetBackoff;
{
    ++self.resetBackoffCount;
}

- (void)increaseBackoff;
{
    ++self.increaseBackoffCount;
}

- (void)tearDown
{
    
}
@end


@implementation FakeDelegate

- (void)handlerDidReceiveAccessToken:(id)sender
{
    (void)sender;
    self.delegateCallCount++;
    
    if (self.didReceiveAccessTokenBlock) {
        self.didReceiveAccessTokenBlock();
    }
}

- (void)handlerDidClearAccessToken:(ZMAccessTokenHandler * __unused)handler
{
    // TODO
}

@end


@implementation FakeGroupQueue

- (void)performGroupedBlock:(dispatch_block_t)block
{
    block();
}

- (ZMSDispatchGroup *)dispatchGroup
{
    return nil;
}

@end

