// 
// 


#import <Foundation/Foundation.h>
#import <WireTransport/ZMTransportData.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(uint8_t, ZMTransportResponseContentType) {
    ZMTransportResponseContentTypeInvalid,
    ZMTransportResponseContentTypeEmpty,
    ZMTransportResponseContentTypeImage,
    ZMTransportResponseContentTypeJSON,
};


typedef NS_ENUM(uint8_t, ZMTransportResponseStatus) {
    ZMTransportResponseStatusSuccess,
    ZMTransportResponseStatusTemporaryError,
    ZMTransportResponseStatusPermanentError,
    ZMTransportResponseStatusExpired,
    ZMTransportResponseStatusTryAgainLater,
};




@interface ZMTransportResponse : NSObject

- (instancetype)initWithHTTPURLResponse:(NSHTTPURLResponse *)HTTPResponse data:(nullable NSData *)data error:(nullable NSError *)error;

- (instancetype)initWithImageData:(NSData *)imageData HTTPStatus:(NSInteger)status transportSessionError:(nullable NSError *)error headers:(nullable NSDictionary *)headers;

- (instancetype)initWithPayload:(nullable id<ZMTransportData>)payload HTTPStatus:(NSInteger)status transportSessionError:(nullable NSError *)error headers:(nullable NSDictionary *)headers;
+ (instancetype)responseWithPayload:(nullable id<ZMTransportData>)payload HTTPStatus:(NSInteger)status transportSessionError:(nullable NSError *)error headers:(nullable NSDictionary *)headers;
+ (instancetype)responseWithPayload:(nullable id<ZMTransportData>)payload HTTPStatus:(NSInteger)status transportSessionError:(nullable NSError *)error;
+ (instancetype)responseWithTransportSessionError:(NSError *)error;

@property (nonatomic, readonly, nullable) id<ZMTransportData> payload;
@property (nonatomic, readonly, nullable) NSData * imageData;
@property (nonatomic, readonly, copy, nullable) NSDictionary * headers;

@property (nonatomic, readonly) NSInteger HTTPStatus;
@property (nonatomic, readonly, nullable) NSError * transportSessionError;
@property (nonatomic) ZMSDispatchGroup *dispatchGroup;

@property (nonatomic, readonly, nullable) NSHTTPURLResponse * rawResponse;
@property (nonatomic, readonly, nullable) NSData * rawData;

@property (nonatomic, readonly) ZMTransportResponseStatus result;

- (nullable NSString *)payloadLabel;

@property (nonatomic, nullable) NSDate *startOfUploadTimestamp;
@end


@interface ZMTransportResponse (PermanentlyUnavailable)
- (BOOL)isPermanentylUnavailableError;
@end


@interface NSHTTPURLResponse (ZMTransportResponse)

- (ZMTransportResponseContentType)zmContentTypeForBodyData:(NSData *)bodyData;

@end

NS_ASSUME_NONNULL_END

