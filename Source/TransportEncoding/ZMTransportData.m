// 
// 


#import "ZMTransportData.h"

@implementation NSDictionary (ZMTransportData)

- (NSDictionary *)asDictionary;
{
    return self;
}
- (NSArray *)asArray;
{
    return nil;
}

- (id)asTransportData
{
    return self;
}

@end

@implementation NSArray (ZMTransportData)

- (NSDictionary *)asDictionary;
{
    return nil;
}
- (NSArray *)asArray;
{
    return self;
}

- (id)asTransportData
{
    return self;
}

@end

@implementation NSString (ZMTransportData)

- (NSDictionary *)asDictionary
{
    return nil;
}

- (NSArray *)asArray
{
    return nil;
}

- (id)asTransportData
{
    return self;
}

@end
