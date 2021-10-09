//
//

import Foundation

@objc
class MockURLAuthenticationChallengeSender: NSObject, URLAuthenticationChallengeSender {
    
    func use(_ credential: URLCredential, for challenge: URLAuthenticationChallenge) {
        
    }
    
    func continueWithoutCredential(for challenge: URLAuthenticationChallenge) {
        
    }
    
    func cancel(_ challenge: URLAuthenticationChallenge) {
        
    }
    
}
