// 
// 



#import "NSString+UUID.h"
#import "NSObject+ZMTransportEncoding.h"

@implementation NSString (UUID)

- (NSUUID *)UUID
{
    return [NSUUID uuidWithTransportString:self];
}

@end
