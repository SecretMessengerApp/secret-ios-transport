// 
// 


@import ImageIO;
@import MobileCoreServices;
@import WireSystem;

#import "ZMTransportResponse.h"


#import "ZMTransportData.h"
#import "ZMTransportCodec.h"
#import "ZMTransportSession.h"
#import "Collections+ZMTSafeTypes.h"
#import "ZMTLogging.h"
#import <WireTransport/WireTransport-Swift.h>


static NSString* ZMLogTag ZM_UNUSED = ZMT_LOG_TAG_NETWORK;


@interface ZMTransportResponse()

@property (nonatomic) NSHTTPURLResponse *rawResponse;
@property (nonatomic) NSData *rawData;

@end


@implementation ZMTransportResponse

- (instancetype)initWithHTTPURLResponse:(NSHTTPURLResponse *)HTTPResponse data:(NSData *)data error:(NSError *)error;
{
    switch ([HTTPResponse zmContentTypeForBodyData:data]) {
        case ZMTransportResponseContentTypeImage: {
            self = [self initWithImageData:data HTTPStatus:HTTPResponse.statusCode transportSessionError:error headers:HTTPResponse.allHeaderFields];
            break;
        }
        case ZMTransportResponseContentTypeJSON: {
            id<ZMTransportData> responsePayload = [ZMTransportCodec interpretResponse:HTTPResponse data:data error:error];
            self = [self initWithPayload:responsePayload HTTPStatus:HTTPResponse.statusCode transportSessionError:error headers:HTTPResponse.allHeaderFields];
            break;
        }
        case ZMTransportResponseContentTypeEmpty: {
            self = [self initWithPayload:nil HTTPStatus:HTTPResponse.statusCode transportSessionError:error headers:HTTPResponse.allHeaderFields];
            break;
        }
        default:
        {
            self = [self initWithPayload:nil HTTPStatus:HTTPResponse.statusCode transportSessionError:error headers:HTTPResponse.allHeaderFields];
            self.rawData = data;
            break;
        }
    }
    
    self.rawResponse = HTTPResponse;
    return self;
}

- (instancetype)initWithImageData:(NSData *)imageData HTTPStatus:(NSInteger)status transportSessionError:(NSError *)error headers:(NSDictionary *)headers;
{
    return [self initWithImageData:imageData payload:nil HTTPStatus:status networkError:error headers:headers];
}


- (instancetype)initWithPayload:(id<ZMTransportData>)payload HTTPStatus:(NSInteger)status transportSessionError:(NSError *)error headers:(NSDictionary *)headers;
{
    return [self initWithImageData:nil payload:payload HTTPStatus:status networkError:error headers:headers];
}

- (instancetype)initWithImageData:(NSData *)imageData payload:(id<ZMTransportData>)payload HTTPStatus:(NSInteger)status networkError:(NSError *)error headers:(NSDictionary *)headers
{
    self = [super init];
    if(self) {
        _transportSessionError = error;
        CheckString((_transportSessionError == nil) || [_transportSessionError.domain isEqualToString:ZMTransportSessionErrorDomain], "Unexpected error domain");
        _payload = payload;
        _imageData = [imageData copy];
        _HTTPStatus = status;
        _headers = headers;
        
        self.rawResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@""] statusCode:status HTTPVersion:@"HTTP/1.1" headerFields:headers];
        self.rawData = self.imageData ?: [ZMTransportCodec encodedTransportData:self.payload];
    }
    return self;
}

+ (instancetype)responseWithPayload:(id<ZMTransportData>)payload HTTPStatus:(NSInteger)status transportSessionError:(NSError *)error headers:(NSDictionary *)headers;
{
    return [[self alloc] initWithPayload:payload HTTPStatus:status transportSessionError:error headers:headers];
}

+ (instancetype)responseWithPayload:(id<ZMTransportData>)payload HTTPStatus:(NSInteger)status transportSessionError:(NSError *)error;
{
    return [self responseWithPayload:payload HTTPStatus:status transportSessionError:error headers:nil];
}

+ (instancetype)responseWithTransportSessionError:(NSError *)error;
{
    return [self responseWithPayload:nil HTTPStatus:0 transportSessionError:error headers:nil];
}


- (ZMTransportResponseStatus)result
{
    if (self.transportSessionError) {
        if ([self.transportSessionError.domain isEqualToString:ZMTransportSessionErrorDomain]) {
            switch ((ZMTransportSessionErrorCode) self.transportSessionError.code) {
                case ZMTransportSessionErrorCodeRequestExpired:
                    return ZMTransportResponseStatusExpired;
                case ZMTransportSessionErrorCodeTryAgainLater:
                    return ZMTransportResponseStatusTryAgainLater;
                case ZMTransportSessionErrorCodeAuthenticationFailed:
                    return ZMTransportResponseStatusPermanentError;
                default:
                    ZMLogWarn(@"Invalid ZMTransportSessionErrorCode %d", (int) self.transportSessionError.code);
                    break;
            }
        } else {
            ZMLogError(@"Unknown error domain: %@", self.transportSessionError.domain);
            return ZMTransportResponseStatusTryAgainLater;
        }
    }
    if(self.HTTPStatus == 408) {
        // According to HTTP specifications: "The client did not produce a request within the time
        // that the server was prepared to wait. The client MAY repeat the request without modifications at any later time."
        return ZMTransportResponseStatusTryAgainLater;
    }
    if (self.HTTPStatus >= 100 && self.HTTPStatus < 300) {
        return ZMTransportResponseStatusSuccess;
    }
    if (self.HTTPStatus >= 300 && self.HTTPStatus < 500) {
        return ZMTransportResponseStatusPermanentError;
    }
    if (self.HTTPStatus != 0) {
        return ZMTransportResponseStatusTemporaryError;
    }
    // Should not reach this point
    VerifyReturnValue(NO, ZMTransportResponseStatusTryAgainLater);
}

- (NSString *)payloadLabel
{
    return [[self.payload asDictionary] optionalStringForKey:@"label"];
}


- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@: %p> %@ %@ %@", [self class], self, self.transportSessionError ?: [NSNumber numberWithLong:self.HTTPStatus], self.headers, self.payload];
}


@end


@implementation ZMTransportResponse (PermanentlyUnavailable)

- (BOOL)isPermanentylUnavailableError
{
    static uint16_t const permanentylUnavailableHTTPResponseCodes[] = {400, 403, 404, 405, 406, 410, 412, 451};
    static size_t const length = sizeof(permanentylUnavailableHTTPResponseCodes)/sizeof(permanentylUnavailableHTTPResponseCodes[0]);

    if (self.result != ZMTransportResponseStatusPermanentError) {
        return NO;
    }
    
    for (size_t index = 0; index < length; index++) {
        if (permanentylUnavailableHTTPResponseCodes[index] == self.HTTPStatus) {
            return YES;
        }
    }
    
    return NO;
}

@end



@implementation NSHTTPURLResponse (ZMTransportResponse)

- (ZMTransportResponseContentType)zmContentTypeForBodyData:(NSData *)bodyData;
{
    if ((bodyData != nil) && (bodyData.length == 0)) {
        return ZMTransportResponseContentTypeEmpty;
    }
    NSString *contentLength = self.allHeaderFields[@"Content-Length"];
    if (contentLength != nil) {
        NSScanner *scanner = [NSScanner scannerWithString:contentLength];
        unsigned long long length = 0;
        if ([scanner scanUnsignedLongLong:&length] && (length == 0)) {
            return ZMTransportResponseContentTypeEmpty;
        }
    }
    
    NSString *contentType = self.allHeaderFields[@"Content-Type"];
    NSString *type = CFBridgingRelease(UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef) contentType, kUTTypeContent));
    if (type != nil) {
        if (UTTypeConformsTo((__bridge CFStringRef) type, kUTTypeImage)) {
            return ZMTransportResponseContentTypeImage;
        }
        BOOL hasJSONSupport = (&UTTypeIsDynamic != NULL);
        if (hasJSONSupport && UTTypeConformsTo((__bridge CFStringRef) type, kUTTypeJSON)) {
            return ZMTransportResponseContentTypeJSON;
        }
    }
    // UTI / Core Services couldn't help us.
    for (NSString *prefix in @[@"application/json",
                               @"text/x-json"]) {
        if ([contentType hasPrefix:prefix]) {
            return ZMTransportResponseContentTypeJSON;
        }
    }
    if ([contentType hasPrefix:@"application/binary"]) {
        // Fire up ImageIO
        CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef) bodyData, NULL);
        if (source != NULL) {
            type = [(__bridge id) CGImageSourceGetType(source) copy];
            CFRelease(source);
        }
        if (UTTypeConformsTo((__bridge CFStringRef) type, kUTTypeImage)) {
            return ZMTransportResponseContentTypeImage;
        }
    }
    return ZMTransportResponseContentTypeInvalid;
}

@end
