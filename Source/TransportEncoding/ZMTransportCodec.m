// 
// 


#import "ZMTransportCodec.h"


@implementation ZMTransportCodec

+ (id<ZMTransportData>)interpretResponse:(NSHTTPURLResponse *)response data:(NSData *)data error:(NSError *)error;
{
    if ((data == nil) || (error != nil) || response.statusCode >= 500) {
        return nil;
    }
    
    // checks that the type is the expected one
    NSString *contentType = [[response allHeaderFields] objectForKey:@"Content-Type"];
    if(!contentType) {
        return nil;
    }
    NSString *firstToken = [contentType componentsSeparatedByString:@";"][0];
    if(! [[firstToken stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[ZMTransportCodec encodedContentType]]) {
        return nil;
    }
    
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}



+ (NSData *)encodedTransportData:(id<ZMTransportData>)object
{
    if (!object) {
        return [NSData data];
    }
    if ([object isKindOfClass:[NSString class]]) {
        NSString *string = (NSString *)object;
        return [string dataUsingEncoding:NSUTF8StringEncoding];
    }
    NSError *error;
    return [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
}

+ (NSString *)encodedContentType
{
    return @"application/json";
}

@end



@implementation NSDictionary (TransportData)
@end



@implementation NSArray (TransportData)
@end
