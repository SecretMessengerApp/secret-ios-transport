//
//

import Foundation
import WireTransport

class TestTrustVerificator: NSObject, URLSessionDelegate {

    var session: URLSession!
    var trustProvider: BackendTrustProvider!
    private let callback: (Bool) -> Void

    init(trustProvider: BackendTrustProvider = MockCertificateTrust(), callback: @escaping (Bool) -> Void) {
        self.callback = callback
        super.init()
        session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        self.trustProvider = trustProvider
    }

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let protectionSpace = challenge.protectionSpace
        guard protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust else { return callback(false) }
        let trusted = trustProvider.verifyServerTrust(trust: protectionSpace.serverTrust!, host: protectionSpace.host)
        callback(trusted)
    }

    func verify(url: URL) {
        session.dataTask(with: url).resume()
    }

}
