// 
// 


#import <Foundation/Foundation.h>
#import <WireTransport/ZMTransportData.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZMTransportCodec : NSObject

/// interprets the response and tries to parse the body as a JSON
+ (nullable id<ZMTransportData>) interpretResponse:(NSHTTPURLResponse *)response data:(nullable NSData *)data error:(nullable NSError *)error;

+ (NSData *)encodedTransportData:(id<ZMTransportData>)object;

/// gets the Content-Type header content for the encoded data
+ (NSString *)encodedContentType;

@end

NS_ASSUME_NONNULL_END
