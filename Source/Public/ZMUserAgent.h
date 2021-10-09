// 
// 


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZMUserAgent : NSObject

+ (void)setUserAgentOnRequest:(NSMutableURLRequest *)request;
+ (NSString *)userAgentValue;
+ (void)setWireAppVersion:(NSString *)appVersion;

@end

NS_ASSUME_NONNULL_END
