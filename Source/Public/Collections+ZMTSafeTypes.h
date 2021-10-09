// 
// 


#import <Foundation/Foundation.h>

@interface NSArray (ZMSafeTypes)

/// Returns a copy of the array where all elements are dictionaries. Non-dictionaries are filtered out
- (NSArray *)asDictionaries;

@end
