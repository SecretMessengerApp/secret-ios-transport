// 
// 


@import Foundation;
@import WireSystem;

@class DataBuffer;


typedef NS_ENUM(uint8_t, ZMWebSocketFrameType) {
    ZMWebSocketFrameTypeInvalid = 0,
    ZMWebSocketFrameTypeText,
    ZMWebSocketFrameTypeBinary,
    ZMWebSocketFrameTypePing,
    ZMWebSocketFrameTypePong,
    ZMWebSocketFrameTypeClose,
};

extern NSString * const ZMWebSocketFrameErrorDomain;
typedef NS_ENUM(NSInteger, ZMWebSocketFrameErrorCode) {
    ZMWebSocketFrameErrorCodeInvalid = 0,
    ZMWebSocketFrameErrorCodeDataTooShort,
    ZMWebSocketFrameErrorCodeParseError,
};





/// Web Socket Frame according to RFC 6455
/// http://tools.ietf.org/html/rfc6455
@interface ZMWebSocketFrame : NSObject

/// The passed in error will be set to @c ZMWebSocketFrameErrorDomain and one of
/// @c ZMWebSocketFrameErrorCodeDataTooShort or @c ZMWebSocketFrameErrorCodeParseError
- (instancetype)initWithDataBuffer:(DataBuffer *)dataBuffer error:(NSError **)error NS_DESIGNATED_INITIALIZER ZM_NON_NULL(1, 2);

/// Creates a binary frame with the given payload.
- (instancetype)initWithBinaryFrameWithPayload:(NSData *)payload NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithTextFrameWithPayload:(NSString *)payload NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithPongFrame NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithPingFrame NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) ZMWebSocketFrameType frameType;
@property (nonatomic, readonly, copy) NSData *payload;

@property (nonatomic, readonly) dispatch_data_t frameData;

@end
