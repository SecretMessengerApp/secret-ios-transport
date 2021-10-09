////
//

@interface ZMPersistentCookieStorage (Testing)


/**
 Disable/enable keychain access. This method should be called for testing only

 @param disabled true if not persist to keychain
 */
+ (void)setDoNotPersistToKeychain:(BOOL)disabled;

@end
