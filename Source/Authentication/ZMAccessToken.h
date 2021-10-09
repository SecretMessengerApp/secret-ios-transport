// 
// 


#import <Foundation/Foundation.h>


@interface ZMAccessToken : NSObject

- (instancetype)initWithToken:(NSString *)token type:(NSString *)type expiresInSeconds:(NSUInteger)seconds;

@property (nonatomic, readonly) NSString *token;
@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) NSDate *expirationDate;
@property (nonatomic, readonly) NSDictionary *httpHeaders;


@end
