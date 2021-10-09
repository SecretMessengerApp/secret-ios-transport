// 
// 


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Maps NSUInteger to @c id
///
/// It is very similar to an NSDictionary, but uses NSUInteger as keys in stead of @c id<NSCopying>
@interface ZMTaskIdentifierMap : NSObject

- (nullable id)objectForTaskIdentifier:(NSUInteger)taskIdentifier;
- (void)setObject:(id)object forTaskIdentifier:(NSUInteger)taskIdentifier;
- (void)removeObjectForTaskIdentifier:(NSUInteger)taskIdentifier;

- (nullable id)objectAtIndexedSubscript:(NSUInteger)idx;
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(NSUInteger taskIdentifier, id obj, BOOL *stop))block;
- (NSUInteger)count;
- (void)removeAllObjects;

@end

NS_ASSUME_NONNULL_END
