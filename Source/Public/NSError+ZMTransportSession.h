// 
// 


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSError (ZMTransportSession)

- (BOOL)isCancelledURLTaskError;
- (BOOL)isTimedOutURLTaskError;
- (BOOL)isURLTaskNetworkError;

+ (NSError *)requestExpiredError;
+ (NSError *)tryAgainLaterError;
+ (NSError *)tryAgainLaterErrorWithUserInfo:(nullable NSDictionary *)userInfo;


/// @c YES if the request what cancelled
@property (nonatomic, readonly) BOOL isExpiredRequestError;

/// If @c YES the request should be re-enqueued at a later point in time.
///
/// If the sender can re-enqueue the error (e.g. ZMUpstreamModifiedObjectSync et al.) it should reset the state for the corresponding object.
/// If the sender can @e not re-enqueue if should assume that the request failed.
@property (nonatomic, readonly) BOOL isTryAgainLaterError;


+ (nullable NSError *)transportErrorFromURLTask:(NSURLSessionTask *)task expired:(BOOL)expired;

@end

NS_ASSUME_NONNULL_END
