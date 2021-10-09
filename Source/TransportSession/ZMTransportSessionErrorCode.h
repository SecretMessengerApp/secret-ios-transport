// 
// 



typedef NS_ENUM(NSInteger, ZMTransportSessionErrorCode) {
    ZMTransportSessionErrorCodeInvalidCode = 0, ///< Should never be used
    ZMTransportSessionErrorCodeAuthenticationFailed, ///< Unable to get access token / cookie
    ZMTransportSessionErrorCodeRequestExpired, ///< Request went over its expiration date
    ZMTransportSessionErrorCodeTryAgainLater, ///< c.f. @code -[NSError isTryAgainLaterError] @endcode
};
