// 
// 


#import <Foundation/Foundation.h>

@interface ZMTaskIdentifier : NSObject <NSCoding>

@property (nonatomic, readonly) NSUInteger identifier;
@property (nonatomic, readonly) NSString *sessionIdentifier;
@property (nonatomic, readonly) NSData *data;

+ (instancetype)identifierWithIdentifier:(NSUInteger)identifier sessionIdentifier:(NSString *)sessionIdentifier;
+ (instancetype)identifierFromData:(NSData *)data;

@end
