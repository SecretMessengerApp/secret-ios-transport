// 
// 


@protocol ZMBackgroundable

/// Enter background mode
- (void)enterBackground;
/// Enter foreground mode
- (void)enterForeground;
/// Called when we're done with preparing for backgrounding.
/// Last chance to do anything before getting suspended
- (void)prepareForSuspendedState;

@end
