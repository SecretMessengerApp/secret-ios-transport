// 
// 


#import <Foundation/Foundation.h>

@protocol ZMWebSocketConsumer;
@protocol ZMSGroupQueue;
@protocol BackendTrustProvider;
@class NetworkSocket;

extern NSString * const ZMWebSocketErrorDomain;
typedef NS_ENUM(NSInteger, ZMWebSocketErrorCode) {
    ZMWebSocketErrorCodeInvalid = 0,
    ZMWebSocketErrorCodeLostConnection
};


@interface ZMWebSocket : NSObject

- (instancetype)initWithConsumer:(id<ZMWebSocketConsumer>)consumer
                           queue:(dispatch_queue_t)queue
                           group:(ZMSDispatchGroup *)group
                             url:(NSURL *)url
                   trustProvider:(id<BackendTrustProvider>)trustProvider
          additionalHeaderFields:(NSDictionary *)additionalHeaderFields;

- (instancetype)initWithConsumer:(id<ZMWebSocketConsumer>)consumer
                           queue:(dispatch_queue_t)queue
                           group:(ZMSDispatchGroup *)group
                   networkSocket:(NetworkSocket *)networkSocket
              networkSocketQueue:(dispatch_queue_t)queue
                             url:(NSURL *)url
                   trustProvider:(id<BackendTrustProvider>)trustProvider
          additionalHeaderFields:(NSDictionary *)additionalHeaderFields NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly, weak) id<ZMWebSocketConsumer> consumer;

- (void)close;
- (void)sendTextFrameWithString:(NSString *)string;
- (void)sendBinaryFrameWithData:(NSData *)data;
- (void)sendPingFrame;


/**
 When this object is created, hand shake is initialized as not complete.
 After didParseHandshakeInBuffer is called and handshaked sucessfully this method will return true.

 @return return ture if handshake is completed
 */
- (BOOL)handshakeCompleted;

@end

@protocol ZMWebSocketConsumer <NSObject>

- (void)webSocketDidCompleteHandshake:(ZMWebSocket *)websocket HTTPResponse:(NSHTTPURLResponse *)response;
- (void)webSocket:(ZMWebSocket *)webSocket didReceiveFrameWithData:(NSData *)data;
- (void)webSocket:(ZMWebSocket *)webSocket didReceiveFrameWithText:(NSString *)text;
- (void)webSocketDidClose:(ZMWebSocket *)webSocket HTTPResponse:(NSHTTPURLResponse *)response error:(NSError *)error;

@end
