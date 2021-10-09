//
//


#import <Foundation/Foundation.h>
#import <WireTransport/ZMTransportResponse.h>
#import <WireTransport/ZMTransportRequest.h>
#import <WireTransport/ZMReachability.h>
#import <WireTransport/ZMBackgroundable.h>
#import <WireTransport/ZMRequestCancellation.h>
#import <WireTransport/ZMURLSession.h>

NS_ASSUME_NONNULL_BEGIN

@class UIApplication;
@class ZMAccessToken;
@class ZMTransportRequest;
@class ZMPersistentCookieStorage;
@class ZMTransportRequestScheduler;
@protocol ZMPushChannelConsumer;
@protocol ZMSGroupQueue;
@protocol ZMKeyValueStore;
@protocol ZMPushChannel;
@protocol ReachabilityProvider;
@protocol BackendEnvironmentProvider;
@protocol URLSessionsDirectory;
@class ZMTransportRequest;

typedef ZMTransportRequest* _Nullable (^ZMTransportRequestGenerator)(void);

extern NSString * const ZMTransportSessionNewRequestAvailableNotification;

@interface ZMBackTransportSession : NSObject

@property (nonatomic, nullable) ZMAccessToken *accessToken;
@property (nonatomic) NSURL *baseURL;
@property (nonatomic) NSURL *websocketURL;
@property (nonatomic, readonly) NSOperationQueue *workQueue;
@property (nonatomic, assign) NSInteger maximumConcurrentRequests;
@property (nonatomic, readonly) ZMPersistentCookieStorage *cookieStorage;
@property (nonatomic, copy) void (^requestLoopDetectionCallback)(NSString*);
@property (nonatomic, readonly) id<ReachabilityProvider, TearDownCapable> reachability;

- (instancetype)initWithEnvironment:(id<BackendEnvironmentProvider>)environment
                      cookieStorage:(ZMPersistentCookieStorage *)cookieStorage
                       reachability:(id<ReachabilityProvider, TearDownCapable>)reachability
                 initialAccessToken:(nullable ZMAccessToken *)initialAccessToken
         applicationGroupIdentifier:(nullable NSString *)applicationGroupIdentifier;

- (void)tearDown;

/// Sets the access token failure callback. This can be called only before the first request is fired
- (void)setAccessTokenRenewalFailureHandler:(ZMCompletionHandlerBlock)handler NS_SWIFT_NAME(setAccessTokenRenewalFailureHandler(handler:)); //TODO accesstoken // move this out of here?

/// Sets the access token success callback
- (void)setAccessTokenRenewalSuccessHandler:(ZMAccessTokenHandlerBlock)handler;

- (void)enqueueOneTimeRequest:(ZMTransportRequest *)searchRequest NS_SWIFT_NAME(enqueueOneTime(_:));

- (ZMTransportEnqueueResult *)attemptToEnqueueSyncRequestWithGenerator:(NS_NOESCAPE ZMTransportRequestGenerator)requestGenerator NS_SWIFT_NAME(attemptToEnqueueSyncRequest(generator:));

/**
 *   This method should be called from inside @c application(application:handleEventsForBackgroundURLSession identifier:completionHandler:)
 *   and passed the identifier and completionHandler to store after recreating the background session with the given identifier.
 *   We need to store the handler to call it as soon as the background download completed (in @c URLSessionDidFinishEventsForBackgroundURLSession(session:))
 */
- (void)addCompletionHandlerForBackgroundSessionWithIdentifier:(NSString *)identifier handler:(dispatch_block_t)handler NS_SWIFT_NAME(addCompletionHandlerForBackgroundSession(identifier:handler:));

/**
 *   Asynchronically gets all current @c NSURLSessionTasks for the background session and calls the completionHandler
 *   with them as parameter, can be used to check if a request that is expected to be registered with the
 *   background session indeed is, e.g. after the app has been terminated
 */
- (void)getBackgroundTasksWithCompletionHandler:(void (^)(NSArray <NSURLSessionTask *>*))completionHandler;

@end

@interface ZMBackTransportSession (RequestScheduler) <ZMTransportRequestSchedulerSession>
@end



@interface ZMBackTransportSession (URLSessionDelegate) <ZMURLSessionDelegate>
@end


NS_ASSUME_NONNULL_END
