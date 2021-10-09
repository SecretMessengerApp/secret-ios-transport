// 
// 


#import <Foundation/Foundation.h>


@protocol ZMTransportEncoding <NSObject>

- (nonnull NSString *)transportString;

@end



@interface NSDate (ZMTransportEncoding) <ZMTransportEncoding>

+ (nullable instancetype)dateWithTransportString:(nonnull NSString *)transportString;

@end



@interface NSUUID (ZMTransportEncoding) <ZMTransportEncoding>

+ (nullable instancetype)uuidWithTransportString:(nonnull NSString *)transportString;

@end
