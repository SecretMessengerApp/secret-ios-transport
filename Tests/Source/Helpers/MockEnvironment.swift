//
//

import Foundation

public class MockEnvironment: NSObject, BackendEnvironmentProvider {
    
    public func verifyServerTrust(trust: SecTrust, host: String?) -> Bool {
        return true
    }
    public var title: String = "Example"
    public var backendURL: URL = URL(string: "http://example.com")!
    public var backendWSURL: URL = URL(string: "http://example.com")!
    public var blackListURL: URL = URL(string: "https://clientblacklist.wire.com/prod/ios")!
    public var teamsURL: URL = URL(string: "http://example.com")!
    public var accountsURL: URL = URL(string: "http://example.com")!
    public var websiteURL: URL = URL(string: "http://example.com")!
    public var environmentType: EnvironmentTypeProvider = EnvironmentTypeProvider(environmentType: .production)
}
