// 
// 


#import <Foundation/Foundation.h>
#import <WireSystem/WireSystem.h>
@import WireUtilities;

NS_ASSUME_NONNULL_BEGIN

@class ZMTransportRequest;
@class ZMTimer;
@class ZMURLSession;
@protocol ZMURLSessionDelegate;
@protocol BackendTrustProvider;

extern NSString * const ZMURLSessionBackgroundIdentifier;
extern NSString * const ZMURLSessionForegroundIdentifier;
extern NSString * const ZMURLSessionVoipIdentifier;

@interface ZMURLSession : NSObject <TearDownCapable>

@property (nonatomic, readonly) NSString *identifier;

- (instancetype)initWithConfiguration:(NSURLSessionConfiguration *)configuration
                        trustProvider:(id<BackendTrustProvider>)trustProvider
                             delegate:(id<ZMURLSessionDelegate>)delegate
                        delegateQueue:(NSOperationQueue *)queue
                           identifier:(NSString *)identifier;

- (void)setTimeoutTimer:(ZMTimer *)timer forTask:(NSURLSessionTask *)task;

- (void)cancelAndRemoveAllTimers;
- (void)cancelAllTasksWithCompletionHandler:(dispatch_block_t)handler;
- (void)countTasksWithCompletionHandler:(void(^)(NSUInteger count))handler;
- (void)getTasksWithCompletionHandler:(void (^)(NSArray <NSURLSessionTask *>*))completionHandler;

- (void)tearDown;

/// The completion handler will be called with YES if the task was cancelled.
- (void)cancelTaskWithIdentifier:(NSUInteger)taskIdentifier completionHandler:(nullable void(^)(BOOL))handler;

@property (nonatomic, readonly) NSURLSessionConfiguration *configuration;

@end




@interface ZMURLSession (TaskGeneration)

@property (nonatomic, readonly) BOOL isBackgroundSession;

- (nullable NSURLSessionTask *)taskWithRequest:(NSURLRequest *)request bodyData:(nullable NSData *)bodyData transportRequest:(nullable ZMTransportRequest *)request;

@end



@protocol ZMURLSessionDelegate

- (void)URLSession:(ZMURLSession *)URLSession
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler;

- (void)URLSessionDidReceiveData:(ZMURLSession *)URLSession;

- (void)URLSession:(ZMURLSession *)URLSession didDetectUnsafeConnectionToHost:(NSString *)host;

- (void)URLSession:(ZMURLSession *)URLSession
   taskDidComplete:(NSURLSessionTask *)task
  transportRequest:(ZMTransportRequest *)transportRequest
      responseData:(NSData *)responseData;

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(ZMURLSession *)URLSession;

@end

NS_ASSUME_NONNULL_END
