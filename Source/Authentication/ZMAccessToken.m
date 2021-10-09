// 
// 



#import "ZMAccessToken.h"
@import WireSystem;



@interface ZMAccessToken ()

@property (nonatomic) NSString *token;
@property (nonatomic) NSString *type;
@property (nonatomic) NSDate *expirationDate;

@end


@implementation ZMAccessToken
{

}
- (instancetype)initWithToken:(NSString *)token type:(NSString *)type expiresInSeconds:(NSUInteger)seconds;
{
    self = [super init];
    if (self) {
        self.token = token;
        self.type = type;
        self.expirationDate = [NSDate dateWithTimeIntervalSinceNow:seconds];
    }

    return self;
}

- (NSDictionary *)httpHeaders
{
    return @{@"Authorization" : [NSString stringWithFormat:@"%@ %@", self.type, self.token]};
}

- (NSString *)debugDescription;
{
    return [NSString stringWithFormat:@"<%@: %p> type: %@, token: %@, expires in %lld seconds",
            self.class, self,
            self.type, self.token,
            llround([self.expirationDate timeIntervalSinceNow])];
}

@end
