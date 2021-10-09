//
//

import Foundation

class BackendEndpoints: NSObject, BackendEndpointsProvider, Codable {
    let backendURL: URL
    let backendWSURL: URL
    let blackListURL: URL
    let teamsURL: URL
    let accountsURL: URL
    let websiteURL: URL
    
    init(backendURL: URL, backendWSURL: URL, blackListURL: URL, teamsURL: URL, accountsURL: URL, websiteURL: URL) {
        self.backendURL = backendURL
        self.backendWSURL = backendWSURL
        self.blackListURL = blackListURL
        self.teamsURL = teamsURL
        self.accountsURL = accountsURL
        self.websiteURL = websiteURL
        super.init()
    }
}
