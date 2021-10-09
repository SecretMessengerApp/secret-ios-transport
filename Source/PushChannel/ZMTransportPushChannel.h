// 
// 


@import Foundation;
#import "ZMReachability.h"
#import "ZMPushChannel.h"

@class ZMTransportRequestScheduler;
@class ZMAccessToken;
@protocol ZMPushChannelConsumer;
@protocol ZMSGroupQueue;
@protocol ZMReachabilityObserver;
@protocol BackendEnvironmentProvider;

/// This class is responsible for opening and closing the push channel connection to the backend.
@interface ZMTransportPushChannel : NSObject <ZMReachabilityObserver, ZMPushChannel>

/// When set not to nil an attempt open the push channel will be made
@property (nonatomic) ZMAccessToken *accessToken;
@property (nonatomic, weak) id <ZMNetworkStateDelegate> networkStateDelegate;

- (instancetype)initWithScheduler:(ZMTransportRequestScheduler *)scheduler userAgentString:(NSString *)userAgentString environment:(id <BackendEnvironmentProvider>)environment;
- (instancetype)initWithScheduler:(ZMTransportRequestScheduler *)scheduler userAgentString:(NSString *)userAgentString environment:(id <BackendEnvironmentProvider>)environment pushChannelClass:(Class)pushChannelClass NS_DESIGNATED_INITIALIZER;

- (void)setPushChannelConsumer:(id<ZMPushChannelConsumer>)consumer groupQueue:(id<ZMSGroupQueue>)groupQueue;
- (void)closeAndRemoveConsumer;

/// Open push channel connection.
///
/// NOTE: Must be called from transport session queue.
- (void)establishConnection;

/// Will open the push channel if all required conditions are met.
///
/// NOTE: Must be called from transport session queue.
- (void)attemptToOpenPushChannelConnection;

@end
