// 
// 


#import "ZMTaskIdentifier.h"


static NSString * const IdentifierKey = @"identifier";
static NSString * const SessionIdentifierKey = @"sessionIdentifier";


@interface ZMTaskIdentifier ()

@property (nonatomic, readwrite) NSUInteger identifier;
@property (nonatomic, readwrite) NSString *sessionIdentifier;

@end


@implementation ZMTaskIdentifier

+ (instancetype)identifierWithIdentifier:(NSUInteger)identifier sessionIdentifier:(NSString *)sessionIdentifier;
{
    return [[self alloc] initWithIdentifier:identifier sessionIdentifier:sessionIdentifier];
}

- (instancetype)initWithIdentifier:(NSUInteger)identifier sessionIdentifier:(NSString *)sessionIdentifier;
{
    self = [super init];
    if (self) {
        self.identifier = identifier;
        self.sessionIdentifier = sessionIdentifier;
    }
    return self;
}

+ (instancetype)identifierFromData:(NSData *)data
{
    if (nil == data) {
        return nil;
    }
    
    id object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if ([object isKindOfClass:self]) {
        return object;
    }
    
    return nil;
}

- (NSData *)data
{
    return [NSKeyedArchiver archivedDataWithRootObject:self];
}

#pragma mark - Equality

- (BOOL)isEqual:(id)other
{
    if (! [other isKindOfClass:self.class]) {
        return NO;
    }
    ZMTaskIdentifier *otherIdentifier = (ZMTaskIdentifier *)other;
    return self.identifier == otherIdentifier.identifier &&
           [self.sessionIdentifier isEqualToString:otherIdentifier.sessionIdentifier];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.identifier = [[decoder decodeObjectForKey:IdentifierKey] unsignedIntegerValue];
        self.sessionIdentifier = [decoder decodeObjectForKey:SessionIdentifierKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:@(self.identifier) forKey:IdentifierKey];
    [coder encodeObject:self.sessionIdentifier forKey:SessionIdentifierKey];
}

#pragma mark - Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p> identifier: %lu, session identifier: %@",
            self.class, self, (unsigned long)self.identifier, self.sessionIdentifier];
}

@end
