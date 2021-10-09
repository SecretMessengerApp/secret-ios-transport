//
//

#import <Foundation/Foundation.h>

@protocol ZMPushChannel <NSObject>

/// When set not to nil an attempt open the push channel will be made if necessary
@property (nonatomic, nullable) NSString *clientID;

/// When set to YES the push channel will try to remain open and if set to NO it will
/// close immediately and remain closed.
@property (nonatomic) BOOL keepOpen;

@end
