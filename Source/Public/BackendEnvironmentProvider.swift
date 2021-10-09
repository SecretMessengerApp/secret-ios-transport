//
//

import Foundation

@objc public protocol BackendTrustProvider: NSObjectProtocol {
    /// Returns true if certificate matches what we expect it to be OR it's a host we don't need to check
    /// False if certificate doesn't match 
    @objc func verifyServerTrust(trust: SecTrust, host: String?) -> Bool
}

// Wrapper around Swift-only EnvironmentType so that it would be useable in Objective-C
@objc public class EnvironmentTypeProvider: NSObject {
    public var value: EnvironmentType
    init(environmentType: EnvironmentType) {
        self.value = environmentType
    }
}

// Swift migration notice: this protocol conforms to NSObjectProtocol only to be usable from Obj-C.
@objc public protocol BackendEndpointsProvider: NSObjectProtocol {
    /// Backend base URL.
    var backendURL: URL { get }
    /// URL for SSL WebSocket connection.
    var backendWSURL: URL { get }
    /// URL for version blacklist file.
    var blackListURL: URL { get }
    var teamsURL: URL { get }
    var accountsURL: URL { get }
    var websiteURL: URL { get }
}

@objc public protocol BackendEnvironmentProvider: BackendTrustProvider, BackendEndpointsProvider {
    /// Descriptive name of the backend
    var title: String { get }
    
    var environmentType: EnvironmentTypeProvider { get }
}
