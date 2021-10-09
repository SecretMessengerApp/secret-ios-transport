// 
// 


@import WireSystem;

#import "NSObject+ZMTransportEncoding.h"
#import <time.h>
#import <xlocale.h>


static char const * const FormatString = "%Y-%m-%dT%H:%M:%S";
static char const * const RemainderFormatString = ".%03dZ";

static locale_t posixLocale()
{
    static locale_t locale;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        locale = newlocale(LC_ALL_MASK, NULL, NULL);
    });
    return locale;
}



@implementation NSDate (ZMTransportEncoding)

///TODO: review this method for iOS 13 beta, can we retire below 2 methods?
+ (instancetype)dateWithTransportString:(NSString *)transportString;
{
    struct {
        struct tm sometime;
    } s;
    char const * const dateString = [transportString UTF8String];
    VerifyReturnNil(dateString != NULL);
    char const * const remainderString = strptime_l(dateString, FormatString, &s.sometime, posixLocale());
    if (remainderString == NULL) {
        return nil;
    }
    NSTimeInterval interval = timegm(&s.sometime);
    int milli = 0;
    int c = sscanf_l(remainderString, posixLocale(), RemainderFormatString, &milli);
    if (c == 1) {
        interval += 0.001 * milli;
    }
    if (interval < -100) {
        return nil;
    }
    
    return [NSDate dateWithTimeIntervalSince1970:interval];
}

- (NSString *)transportString;
{
    char buffer[80];
    
    struct tm sometime;
    time_t const t = (time_t) floor([self timeIntervalSince1970]);
    (void) gmtime_r(&t, &sometime);
    size_t const c = strftime_l(buffer, sizeof(buffer), FormatString, &sometime, posixLocale());
    RequireString(c != 0, "Could not create transport string from date");
    
    double remainder = [self timeIntervalSince1970] - floor([self timeIntervalSince1970]);
    long milli = (long) fmax(fmin(round(remainder * 1000.), 999), 0);
    int const c2 = snprintf_l(buffer + c, sizeof(buffer) - c, posixLocale(), RemainderFormatString, (int) milli);
    RequireString(c2 != 0, "Could not create transport string from date");

    return [NSString stringWithUTF8String:buffer];
}

@end




@implementation NSUUID (ZMTransportEncoding)

+ (instancetype)uuidWithTransportString:(NSString *)transportString;
{
    return [[NSUUID alloc] initWithUUIDString:transportString];
}

- (NSString *)transportString;
{
    return [[self UUIDString] lowercaseString];
}

@end
