// 
// 


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@import WireSystem;
@import WireUtilities;

@protocol ZMReachabilityObserver;
@protocol ReachabilityProvider;

typedef void (^ReachabilityObserverBlock)(id<ReachabilityProvider> provider);

@protocol ReachabilityProvider

@property (atomic, readonly) BOOL mayBeReachable;
@property (atomic, readonly) BOOL isMobileConnection;
@property (atomic, readonly) BOOL oldMayBeReachable;
@property (atomic, readonly) BOOL oldIsMobileConnection;

/// Register to observe when reachability status changes.
/// Returns a token which should be retained as long as the observer should be active.
- (id)addReachabilityObserver:(id<ZMReachabilityObserver>)observer queue:(nullable NSOperationQueue *)queue;

/// Register to observe when reachability status changes.
/// Returns a token which should be retained as long as the observer should be active.
- (id)addReachabilityObserverOnQueue:(nullable NSOperationQueue *)queue block:(ReachabilityObserverBlock)block;

@end

@interface ZMReachability : NSObject <ReachabilityProvider, TearDownCapable>

/// Calls to the observer will always happen on the specified @c observerQueue . All work will be added to the @c group
- (instancetype)initWithServerNames:(NSArray *)names group:(ZMSDispatchGroup *)group;

- (void)tearDown;

/// When this returns @c NO some of the named servers are definetly not reachable.
/// In reverse, this returns @c YES when there's a chance that we may be able to connect to at least one of the named servers.
@property (atomic, readonly) BOOL mayBeReachable;
@property (atomic, readonly) BOOL isMobileConnection;
@property (atomic, readonly) BOOL oldMayBeReachable;
@property (atomic, readonly) BOOL oldIsMobileConnection;

@end



@protocol ZMReachabilityObserver <NSObject>

- (void)reachabilityDidChange:(id<ReachabilityProvider>)reachability;

@end


@protocol ZMNetworkStateDelegate <NSObject>

- (void)didReceiveData;
- (void)didGoOffline;

@end

NS_ASSUME_NONNULL_END
