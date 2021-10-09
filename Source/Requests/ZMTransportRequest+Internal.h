// 
// 


#import <WireTransport/ZMTransportRequest.h>


@interface ZMTransportRequest (Internal)

@property (nonatomic) NSMutableArray<ZMCompletionHandler *> *completionHandlers;
@property (nonatomic) NSMutableArray<ZMTaskProgressHandler *> *progressHandlers;

+ (NSString *)stringForMethod:(ZMTransportRequestMethod)method;
+ (ZMTransportRequestMethod)methodFromString:(NSString *)string;

- (void)setAdditionalHeaderFieldsOnHTTPRequest:(NSMutableURLRequest *)URLRequest;
- (void)setAcceptedResponseMediaTypeOnHTTPRequest:(NSMutableURLRequest *)URLRequest;
- (void)setBodyDataAndMediaTypeOnHTTPRequest:(NSMutableURLRequest *)URLRequest;
- (void)setContentDispositionOnHTTPRequest:(NSMutableURLRequest *)URLRequest;
- (void)setTimeoutIntervalOnRequestIfNeeded:(NSMutableURLRequest *)request
                  applicationIsBackgrounded:(BOOL)inBackground
                     usingBackgroundSession:(BOOL)usingBackgroundSession;

/// This is intended for logs such that it does not reveal any payload
@property (nonatomic, readonly, copy) NSString *descriptionWithMethodAndPath;
@property (nonatomic, readonly) float progress;

- (void)startBackgroundActivity;

@end
