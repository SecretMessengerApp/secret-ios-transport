//
//

import Foundation

struct TrustData: Decodable {
    struct Host: Decodable {
        enum Rule: String, Decodable {
            case endsWith = "ends_with"
            case equals
        }
        let rule: Rule
        let value: String
    }
    let certificateKey: SecKey
    let hosts: [Host]
    
    enum CodingKeys : String, CodingKey {
        case certificateKey
        case hosts
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let certificateKeyData = try container.decode(Data.self, forKey: .certificateKey)
        
        guard let certificate = SecCertificateCreateWithData(nil, certificateKeyData as CFData) else {
            throw DecodingError.dataCorruptedError(forKey: CodingKeys.certificateKey, in: container, debugDescription: "Error decoding certificate for pinned key")
        }
        
        guard let certificateKey = _SecCertificateCopyPublicKey(certificate) else {
            throw DecodingError.dataCorruptedError(forKey: CodingKeys.certificateKey, in: container, debugDescription: "Error extracting pinned key from certificate")
        }
        self.certificateKey = certificateKey
        self.hosts = try container.decode([TrustData.Host].self, forKey: .hosts)
    }
}

extension TrustData {
    func matches(host: String) -> Bool {
        let matchingHosts = hosts.filter { $0.matches(host: host) }
        return !matchingHosts.isEmpty
    }    
}

extension TrustData.Host {
    func matches(host: String) -> Bool {
        switch rule {
        case .endsWith:
            return host.hasSuffix(value)
        case .equals:
            return host == value
        }
    }
}

