// 
// 


#import "ZMUserAgent.h"
#import <mach-o/dyld.h>
#import <sys/utsname.h>

static NSString *ZMWireAppVersion = nil;
static NSString *ZMUserAgentValue = nil;


@implementation ZMUserAgent

+ (NSString *)deviceName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    if(strlen(systemInfo.machine) > 0) {
        return [NSString stringWithCString:systemInfo.machine
                                  encoding:NSUTF8StringEncoding];
    } else {
        return @"N/A";
    }
}

+ (void)setWireAppVersion:(NSString *)appVersion;
{
    ZMWireAppVersion = [appVersion copy];
    // invalidate user agent cache
    ZMUserAgentValue = nil;
}

+ (void)setUserAgentOnRequest:(NSMutableURLRequest *)request;
{
    [request setValue:[self userAgentValue] forHTTPHeaderField:@"User-Agent"];
}


+ (NSString *)userAgentValue;
{
    if (ZMUserAgentValue == nil) {
        // This is covered by Section 5.5.3 of HTTP/1.1 Semantics and Content
        // <http://tools.ietf.org/html/rfc7231#section-5.5.3>
        //
        // Basically:
        //
        //     ProductName1/Version1 (Comments1) ProductName2/Version2 (Comments2) ...
        
        NSMutableString *agent = [NSMutableString string];
        
        // app version:
        if(ZMWireAppVersion != nil) {
            [agent appendFormat:@"secret/%@ ", ZMWireAppVersion];
        }
        
        // zmessaging:
        [agent appendFormat:@"zmessaging/%@ ", [[[NSBundle bundleForClass:NSClassFromString(@"ZMUserSession")] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
        [agent appendFormat:@"ztransport/%@ ", [[[NSBundle bundleForClass:self] infoDictionary] objectForKey:@"CFBundleVersion"]];
        
        // CFNetwork (which we use for all our networking)
        int32_t version = NSVersionOfRunTimeLibrary("CFNetwork");
        if (version != -1) {
            [agent appendString:@"CFNetwork/"];
            uint16_t const a = ((uint32_t) version) >> 16;
            uint8_t const b = (((uint32_t) version) >> 8) & 0xf;
            uint8_t const c = ((uint32_t) version) & 0xf;
            [agent appendFormat:@"%u.%u.%u", a, b, c];
        }
        
        // device and locale
        [agent appendFormat:@" (iOS; %@)", [NSLocale currentLocale].localeIdentifier];
        
        
        ZMUserAgentValue = [agent copy];
    }
    return ZMUserAgentValue;
}


@end
