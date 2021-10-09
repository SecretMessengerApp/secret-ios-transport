// 
// 


#import <Foundation/Foundation.h>
#import <WireTransport/ZMTransportData.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZMPushChannelConsumer;
@protocol ZMSGroupQueue;
@protocol BackendEnvironmentProvider;
@class ZMWebSocket;
@class ZMAccessToken;



/// This is a one-shot connection to the backend's /await endpoint. Once closed,
/// a new instance needs to be created.
@interface ZMPushChannelConnection : NSObject

- (instancetype)initWithEnvironment:(id <BackendEnvironmentProvider>)environment
                           consumer:(id<ZMPushChannelConsumer>)consumer
                              queue:(id<ZMSGroupQueue>)queue
                        accessToken:(ZMAccessToken *)accessToken
                           clientID:(NSString *)clientID
                    userAgentString:(NSString *)userAgentString;

- (instancetype)initWithEnvironment:(id <BackendEnvironmentProvider>)environment
                           consumer:(id<ZMPushChannelConsumer>)consumer
                              queue:(id<ZMSGroupQueue>)queue
                          webSocket:(nullable ZMWebSocket *)webSocket
                        accessToken:(ZMAccessToken *)accessToken
                           clientID:(nullable NSString *)clientID
                    userAgentString:(NSString *)userAgentString NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly, weak) id<ZMPushChannelConsumer> consumer;
@property (nonatomic, readonly) BOOL isOpen;
@property (nonatomic, readonly) BOOL didCompleteHandshake;

- (void)checkConnection;

- (void)close;

@end



@protocol ZMPushChannelConsumer <NSObject>

- (void)pushChannel:(ZMPushChannelConnection *)channel didReceiveTransportData:(id<ZMTransportData>)data;
- (void)pushChannelDidClose:(ZMPushChannelConnection *)channel withResponse:(nullable NSHTTPURLResponse *)response error:(nullable NSError *)error;
- (void)pushChannelDidOpen:(ZMPushChannelConnection *)channel withResponse:(nullable NSHTTPURLResponse *)response;

@end



@interface ZMPushChannelConnection (Testing)

@property (nonatomic) NSTimeInterval pingInterval;

@end

NS_ASSUME_NONNULL_END
