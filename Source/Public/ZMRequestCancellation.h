// 
// 


@import Foundation;
#import "ZMTaskIdentifier.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZMRequestCancellation <NSObject>

- (void)cancelTaskWithIdentifier:(ZMTaskIdentifier *)taskIdentifier;

@end

NS_ASSUME_NONNULL_END
