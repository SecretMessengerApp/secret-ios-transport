// 
// 


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZMMultipartBodyItem : NSObject

@property (nonatomic, readonly, copy) NSData *data;
@property (nonatomic, readonly, copy, nullable) NSString *contentType;
@property (nonatomic, readonly, copy, nullable) NSDictionary *headers;

- (instancetype)initWithData:(NSData *)data contentType:(NSString *)contentType headers:(nullable NSDictionary *)headers;
- (instancetype)initWithMultipartData:(NSData *)data;

- (BOOL)isEqualToItem:(ZMMultipartBodyItem *)object;

@end

@interface NSData (Multipart)

+ (NSData *)multipartDataWithItems:(NSArray *)items boundary:(NSString *)boundary;

- (NSArray *)multipartDataItemsSeparatedWithBoundary:(NSString *)boundary;

- (NSArray *)componentsSeparatedByData:(NSData *)boundary;
- (NSArray *)lines;


@end

NS_ASSUME_NONNULL_END
