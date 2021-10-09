// 
// 


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZMTransportData <NSObject>

- (nullable NSDictionary *)asDictionary;
- (nullable NSArray *)asArray;
- (nullable id)asTransportData;

@end



@interface NSDictionary (ZMTransportData) <ZMTransportData>
@end



@interface NSArray (ZMTransportData) <ZMTransportData>
@end


@interface NSString (ZMTransportData) <ZMTransportData>
@end

NS_ASSUME_NONNULL_END
