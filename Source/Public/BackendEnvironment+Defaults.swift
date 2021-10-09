//
//

import Foundation

extension BackendEnvironment {

    private static let defaultsKey = "ZMBackendEnvironmentData"

    public convenience init?(userDefaults: UserDefaults, configurationBundle: Bundle) {
        let environmentType = EnvironmentType(userDefaults: userDefaults)
        print("environmentType: \(environmentType)")
        switch environmentType {
        case .production, .staging:
            guard let path = configurationBundle.path(forResource: environmentType.stringValue, ofType: "json") else {
                Logging.backendEnvironment.error("Could not find configuration for \(environmentType.stringValue)")
                return nil
            }
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
                Logging.backendEnvironment.error("Could not read \(path)")
                return nil
            }
            self.init(environmentType: environmentType, data: data)
        case .custom:
            guard let data = userDefaults.data(forKey: BackendEnvironment.defaultsKey) else {
                Logging.backendEnvironment.error("Could not read data from user defaults")
                return nil
            }
            self.init(environmentType: environmentType, data: data)
        }
    }
    
    public func save(in userDefaults: UserDefaults) {
        type.save(in: userDefaults)
        
        switch type {
        case .custom:
            struct SerializedData: Encodable {
                let title: String
                let endpoints: BackendEndpoints
            }
            
            let endpoints = BackendEndpoints(backendURL: self.endpoints.backendURL,
                                             backendWSURL: self.endpoints.backendWSURL,
                                             blackListURL: self.endpoints.blackListURL,
                                             teamsURL: self.endpoints.teamsURL,
                                             accountsURL: self.endpoints.accountsURL,
                                             websiteURL: self.endpoints.websiteURL)
            
            let data = SerializedData(title: title, endpoints: endpoints)
            let encoded = try? JSONEncoder().encode(data)
            userDefaults.set(encoded, forKey: BackendEnvironment.defaultsKey)
        default:
            break
        }
    }
}
