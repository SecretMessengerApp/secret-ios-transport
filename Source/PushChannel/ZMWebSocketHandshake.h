// 
// 


#import <Foundation/Foundation.h>



@class DataBuffer;

typedef NS_ENUM(int16_t, ZMWebSocketHandshakeResult) {
    ZMWebSocketHandshakeNeedsMoreData = 0,
    ZMWebSocketHandshakeCompleted,
    ZMWebSocketHandshakeError
};

@interface ZMWebSocketHandshake : NSObject

- (instancetype)initWithDataBuffer:(DataBuffer *)buffer;
- (ZMWebSocketHandshakeResult)parseAndClearBufferIfComplete:(BOOL)clear error:(NSError **)error;

@property (nonatomic, readonly) NSHTTPURLResponse *response;

@end
