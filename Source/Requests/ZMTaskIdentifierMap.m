// 
// 


@import WireSystem;

#import "ZMTaskIdentifierMap.h"


#if __has_feature(objc_arc)
#error This file needs ARC to be turned off. Add the -fno-objc-arc compiler flag.
#endif


static id keyFromTaskIdentifier(NSUInteger taskIdentifier)
{
    return (void *) (intptr_t) (1 + taskIdentifier);
}

static NSUInteger taskIdentifierFromKey(id key)
{
    return ((NSUInteger) (void *) key) - 1;
}

@implementation ZMTaskIdentifierMap
{
    NSMapTable *_table;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSPointerFunctions *keyPointerFunctions = [[NSPointerFunctions alloc] initWithOptions:(NSPointerFunctionsOpaqueMemory | NSPointerFunctionsIntegerPersonality)];
        NSPointerFunctions *valuePointerFunctions = [[NSPointerFunctions alloc] initWithOptions:(NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPersonality)];
        _table = [[NSMapTable alloc] initWithKeyPointerFunctions:keyPointerFunctions valuePointerFunctions:valuePointerFunctions capacity:1];
        [keyPointerFunctions release];
        [valuePointerFunctions release];
    }
    return self;
}

- (void)dealloc
{
    [_table release];
    [super dealloc];
}

- (id)objectForTaskIdentifier:(NSUInteger)taskIdentifier;
{
    return [_table objectForKey:keyFromTaskIdentifier(taskIdentifier)];
}

- (void)setObject:(id)object forTaskIdentifier:(NSUInteger)taskIdentifier;
{
    [_table setObject:object forKey:keyFromTaskIdentifier(taskIdentifier)];
}

- (void)removeObjectForTaskIdentifier:(NSUInteger)taskIdentifier;
{
    [_table removeObjectForKey:keyFromTaskIdentifier(taskIdentifier)];
}

- (id)objectAtIndexedSubscript:(NSUInteger)taskIdentifier;
{
    return [self objectForTaskIdentifier:taskIdentifier];
}

- (void)setObject:(id)object atIndexedSubscript:(NSUInteger)taskIdentifier;
{
    [self setObject:object forTaskIdentifier:taskIdentifier];
}

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(NSUInteger taskIdentifier, id obj, BOOL *stop))block;
{
    __block BOOL stop = NO;
    for (id key in _table) {
        id object = [_table objectForKey:key];
        block(taskIdentifierFromKey(key), object, &stop);
        if (stop) {
            break;
        }
    }
}

- (NSUInteger)count;
{
    return _table.count;
}

- (void)removeAllObjects;
{
    [_table removeAllObjects];
}

- (NSString *)description;
{
    NSMutableArray *entries = [NSMutableArray array];
    [self enumerateKeysAndObjectsUsingBlock:^(NSUInteger taskIdentifier, id obj, BOOL *stop) {
        NOT_USED(stop);
        [entries addObject:[NSString stringWithFormat:@"\t%llu: %@", (unsigned long long) taskIdentifier, obj]];
    }];
    
    return [NSString stringWithFormat:@"<%@: %p> {\n%@\n}",
            self.class, self, [entries componentsJoinedByString:@"\n"]];
}

@end
