// 
// 


@import WireSystem;

#import <WireTransport/ZMTransportSession.h>
#import "ZMPushChannelConnection.h"
#import "ZMTransportRequestScheduler.h"
#import "ZMTransportPushChannel.h"
#import "ZMAccessTokenHandler.h"
#import "ZMURLSession.h"

@class ZMTaskIdentifierMap;
@class ZMReachability;
@class ZMAccessToken;
@protocol URLSessionsDirectory;

@interface ZMTransportSession ()

- (instancetype)initWithURLSessionsDirectory:(id<URLSessionsDirectory, TearDownCapable>)directory
                        requestScheduler:(ZMTransportRequestScheduler *)requestScheduler
                            reachability:(id<ReachabilityProvider, TearDownCapable>)reachability
                                   queue:(NSOperationQueue *)queue
                                   group:(ZMSDispatchGroup *)group
                             environment:(id<BackendEnvironmentProvider>)environment
                        pushChannelClass:(Class)pushChannelClass
                           cookieStorage:(ZMPersistentCookieStorage *)cookieStorage
                      initialAccessToken:(ZMAccessToken *)initialAccessToken NS_DESIGNATED_INITIALIZER;

- (NSURLSessionTask *)suspendedTaskForRequest:(ZMTransportRequest *)request onSession:(ZMURLSession *)session;

@end



@interface ZMTransportSession (RequestScheduler) <ZMTransportRequestSchedulerSession>
@end


@interface ZMTransportSession (Testing)
- (void)setAccessToken:(ZMAccessToken *)accessToken;
@end


@interface ZMTransportSession (URLSessionDelegate) <ZMURLSessionDelegate>
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(ZMURLSession *)URLSession;
@end



@interface ZMTransportSession (ReachabilityObserver) <ZMReachabilityObserver>

- (void)updateNetworkStatusFromDidReadDataFromNetwork;

@end



/// This protocol allows the ZMTransportSession to handle both ZMTransportRequest and ZMPushChannel as scheduled items.
@protocol ZMTransportRequestSchedulerItemAsRequest <NSObject>

/// If the receiver is a transport request, returns @c self, @c nil otherwise
@property (nonatomic, readonly) ZMTransportRequest *transportRequest;
/// If the receiver is a request to open the push channel
@property (nonatomic, readonly) BOOL isPushChannelRequest;

@end



@interface ZMOpenPushChannelRequest : NSObject <ZMTransportRequestSchedulerItem, ZMTransportRequestSchedulerItemAsRequest>
@end



@interface ZMTransportRequest (Scheduler) <ZMTransportRequestSchedulerItem, ZMTransportRequestSchedulerItemAsRequest>
@end


