//
//

import Foundation

class ServerCertificateTrust: NSObject, BackendTrustProvider {
    let trustData: [TrustData]
    
    init(trustData: [TrustData]) {
        self.trustData = trustData
    }
    
    public func verifyServerTrust(trust: SecTrust, host: String?) -> Bool {
        guard let host = host else { return false }
        let pinnedKeys = trustData
            .filter { trustData in
                trustData.matches(host: host)
            }
            .map { trustData in
                trustData.certificateKey
            }
            
        return verifyServerTrustWithPinnedKeys(trust, pinnedKeys)
    }

}
