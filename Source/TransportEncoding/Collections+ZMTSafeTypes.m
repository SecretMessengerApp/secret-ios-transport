// 
// 


@import WireUtilities;
#import "Collections+ZMTSafeTypes.h"
#import "NSObject+ZMTransportEncoding.h"



@implementation NSArray (ZMSafeTypes)

/// Returns a copy of the array where all elements are dictionaries. Non-dictionaries are filtered out
- (NSArray *)asDictionaries;
{
    // XXX OPTIMIZATION: Use NSFastENumeration
    return [self objectsOfClass:NSDictionary.class];
}
@end
