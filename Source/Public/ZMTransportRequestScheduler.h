// 
// 


#import <Foundation/Foundation.h>
#import <WireSystem/WireSystem.h>
#import <WireUtilities/WireUtilities.h>
#import <WireTransport/ZMReachability.h>

NS_ASSUME_NONNULL_BEGIN

@class ZMExponentialBackoff;
@protocol ZMTransportRequestSchedulerItem;
@protocol ZMTransportRequestSchedulerSession;
@protocol ReachabilityProvider;
@protocol ZMReachabilityObserver;

enum {
    TooManyRequestsStatusCode = 429,
    EnhanceYourCalmStatusCode = 420,
    UnauthorizedStatusCode = 401
};



typedef NS_ENUM(int8_t, ZMTransportRequestSchedulerState) {
    ZMTransportRequestSchedulerStateNormal = 1,
    ZMTransportRequestSchedulerStateOffline,
    ZMTransportRequestSchedulerStateFlush,
    ZMTransportRequestSchedulerStateRateLimitedHoldingOff, ///< We are rate limited, and holding off
    ZMTransportRequestSchedulerStateRateLimitedRetrying, ///< We were rate limitied, and are checking again
};

/// For use with @c concurrentRequestCountLimit when there's no limit in effect.
extern NSInteger const ZMTransportRequestSchedulerRequestCountUnlimited;



@interface ZMTransportRequestScheduler : NSObject <ZMReachabilityObserver, ZMSGroupQueue, TearDownCapable>

- (instancetype)initWithSession:(id<ZMTransportRequestSchedulerSession>)session operationQueue:(NSOperationQueue *)queue group:(ZMSDispatchGroup *)group reachability:(id<ReachabilityProvider>)reachability;
- (instancetype)initWithSession:(id<ZMTransportRequestSchedulerSession>)session operationQueue:(NSOperationQueue *)queue group:(ZMSDispatchGroup *)group reachability:(id<ReachabilityProvider>)reachability backoff:(nullable ZMExponentialBackoff *)backoff NS_DESIGNATED_INITIALIZER;

- (void)tearDown;

- (void)addItem:(id<ZMTransportRequestSchedulerItem>)item;
/// The task given access to the NSHTTPURLResponse and NSError.
- (void)processCompletedURLTask:(NSURLSessionTask *)task;
- (void)processCompletedURLResponse:(nullable NSHTTPURLResponse *)response URLError:(nullable NSError *)error;
- (void)processWebSocketError:(NSError *)error;

- (void)sessionDidReceiveAccessToken:(id<ZMTransportRequestSchedulerSession>)session;
/// The scheduler uses this to retry sending requests if it's in offline mode.
- (void)applicationWillEnterForeground;
/// The transport session uses this to determine whether to continue requesting an access token
- (BOOL)canSendRequests;


@property (atomic, readonly) NSInteger concurrentRequestCountLimit;
@property (nonatomic) ZMTransportRequestSchedulerState schedulerState;
@property (nonatomic, readonly) id<ReachabilityProvider> reachability;

@end



@protocol ZMTransportRequestSchedulerItem <NSObject>

@property (nonatomic, readonly) BOOL needsAuthentication;

@end



@protocol ZMTransportRequestSchedulerSession <NSObject>

@property (nonatomic, readonly) BOOL canStartRequestWithAccessToken;
@property (nonatomic, readonly) BOOL accessTokenIsAboutToExpire;
@property (nonatomic, readonly) ZMReachability *reachability;

- (void)sendSchedulerItem:(id<ZMTransportRequestSchedulerItem>)item;
- (void)temporarilyRejectSchedulerItem:(id<ZMTransportRequestSchedulerItem>)item;

- (void)sendAccessTokenRequest;

- (void)schedulerIncreasedMaximumNumberOfConcurrentRequests:(ZMTransportRequestScheduler *)scheduler;
- (void)schedulerWentOffline:(ZMTransportRequestScheduler *)scheduler;

@end



@interface ZMTransportRequestScheduler (Testing)

/// When the scheduler switches to offline mode (because a request failed) but the reachability says that the network may be reachable, the scheduler will switch back to normal mode after this time interval.
@property (nonatomic) NSTimeInterval timeUntilNormalModeWhenNetworkMayBeReachable;

/// When we're rate limited, we wait approximately this many seconds until retrying a single request.
/// The actual time is randomly picked in the range [t/2; 2*t].
@property (nonatomic) NSTimeInterval timeUntilRetryModeWhenRateLimited;

@end

NS_ASSUME_NONNULL_END
