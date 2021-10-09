//
//

import Foundation

public enum EnvironmentType: Equatable {
    case production
    case staging
    case custom(url: URL)

    var stringValue: String {
        switch self {
        case .production:
            return "production"
        case .staging:
            return "staging"
        case .custom(url: let url):
            return "custom-\(url.absoluteString)"
        }
    }

    init(stringValue: String) {
        switch stringValue {
        case EnvironmentType.staging.stringValue:
            self = .staging
        case let value where value.hasPrefix("custom-"):
            let urlString = value.dropFirst("custom-".count)
            if let url = URL(string: String(urlString)) {
                self = .custom(url: url)
            } else {
                self = .production
            }
        default:
            self = .production
        }
    }
}

extension EnvironmentType {
    public static let defaultsKey = "ZMBackendEnvironmentType"
    public static let groupIdentifier = "ApplicationGroupIdentifier"
    
    public init(userDefaults: UserDefaults) {
        if let value = userDefaults.string(forKey: EnvironmentType.defaultsKey) {
            self.init(stringValue: value)
        } else {
            Logging.backendEnvironment.error("Could not load environment type from user defaults, falling back to production")
            self = .production
        }
    }
    
    public func save(in userDefaults: UserDefaults) {
        userDefaults.setValue(self.stringValue, forKey: EnvironmentType.defaultsKey)
    }
}

public class BackendEnvironment: NSObject {
    public let title: String
    let endpoints: BackendEndpointsProvider
    let certificateTrust: BackendTrustProvider
    let type: EnvironmentType
    
    init(title: String, environmentType: EnvironmentType, endpoints: BackendEndpointsProvider, certificateTrust: BackendTrustProvider) {
        self.title = title
        self.type = environmentType
        self.endpoints = endpoints
        self.certificateTrust = certificateTrust
    }
    
    convenience init?(environmentType: EnvironmentType, data: Data) {
        struct SerializedData: Decodable {
            let title: String
            let endpoints: BackendEndpoints
            let pinnedKeys: [TrustData]?
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let backendData = try decoder.decode(SerializedData.self, from: data)
            let pinnedKeys = backendData.pinnedKeys ?? []
            let certificateTrust = ServerCertificateTrust(trustData: pinnedKeys)
            self.init(title: backendData.title, environmentType: environmentType, endpoints: backendData.endpoints, certificateTrust: certificateTrust)
        } catch {
            print("Could not decode information from data: \(error)")
            return nil
        }
    }    
}

extension BackendEnvironment: BackendEnvironmentProvider {
    public var environmentType: EnvironmentTypeProvider {
        return EnvironmentTypeProvider(environmentType: type)
    }
    
    public var backendURL: URL {
        return endpoints.backendURL
    }
    
    public var backendWSURL: URL {
        return endpoints.backendWSURL
    }
    
    public var blackListURL: URL {
        return endpoints.blackListURL
    }
    
    public var teamsURL: URL {
        return endpoints.teamsURL
    }
    
    public var accountsURL: URL {
        return endpoints.accountsURL
    }
    
    public var websiteURL: URL {
        return endpoints.websiteURL
    }

    public func verifyServerTrust(trust: SecTrust, host: String?) -> Bool {
        return certificateTrust.verifyServerTrust(trust: trust, host: host)
    }
}
