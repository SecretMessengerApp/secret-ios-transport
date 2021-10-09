// 
// 


#import <WireTransport/ZMTransportRequest.h>

@class ZMAccessToken;
@class ZMPersistentCookieStorage;
@class ZMAccessTokenHandler;
@class ZMURLSession;
@class ZMExponentialBackoff;

@protocol ZMAccessTokenHandlerDelegate <NSObject>

- (void)handlerDidReceiveAccessToken:(ZMAccessTokenHandler *)handler;
- (void)handlerDidClearAccessToken:(ZMAccessTokenHandler *)handler;

@end


@class ZMSDispatchGroup;


@interface ZMAccessTokenHandler : NSObject

- (instancetype)initWithBaseURL:(NSURL *)baseURL
                  cookieStorage:(ZMPersistentCookieStorage *)cookieStorage
                       delegate:(id<ZMAccessTokenHandlerDelegate>)delegate
                          queue:(NSOperationQueue *)queue
                          group:(ZMSDispatchGroup *)group
                        backoff:(ZMExponentialBackoff *)backoff
             initialAccessToken:(ZMAccessToken *)initialAccessToken;

- (void)setAccessTokenRenewalFailureHandler:(ZMCompletionHandlerBlock)handler;
- (void)setAccessTokenRenewalSuccessHandler:(ZMAccessTokenHandlerBlock)handler;


- (void)checkIfRequest:(ZMTransportRequest *)request needsToFetchAccessTokenInURLRequest:(NSMutableURLRequest *)URLRequest;

/// Returns YES if another request should be generated (e.g. it was a temporary error)
- (BOOL)processAccessTokenResponse:(ZMTransportResponse *)response;

- (BOOL)consumeRequestWithTask:(NSURLSessionTask *)task data:(NSData *)data session:(ZMURLSession *)session shouldRetry:(BOOL)shouldRetry;
;

- (BOOL)hasAccessToken;

- (void)sendAccessTokenRequestWithURLSession:(ZMURLSession *)URLSession;
- (BOOL)accessTokenIsAboutToExpire;
- (BOOL)canStartRequestWithAccessToken;


@property (nonatomic, readonly) ZMAccessToken *accessToken;

@end



@interface ZMAccessTokenHandler (Testing)

@property (nonatomic) ZMAccessToken* testing_accessToken;

@property (nonatomic, readonly) NSURLSessionTask *currentAccessTokenTask;

@end
