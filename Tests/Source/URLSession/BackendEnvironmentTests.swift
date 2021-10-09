//
//

import Foundation
import XCTest
@testable import WireTransport

class BackendEnvironmentTests: XCTestCase {
    
    var backendBundle: Bundle!
    var defaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        let mainBundle = Bundle(for: type(of: self))
        guard let backendBundlePath = mainBundle.path(forResource: "Backend", ofType: "bundle") else { XCTFail("Could not find Backend.bundle"); return }
        guard let backendBundle = Bundle(path: backendBundlePath) else { XCTFail("Could not load Backend.bundle"); return }

        self.backendBundle = backendBundle
        defaults = UserDefaults(suiteName: name)
        EnvironmentType.production.save(in: defaults)
        continueAfterFailure = true
    }
    
    override func tearDown() {
        backendBundle = nil
        super.tearDown()
    }
    
    func testThatWeCanLoadBackendEndpoints() {
        
        guard let environment = BackendEnvironment(userDefaults: defaults, configurationBundle: backendBundle) else { XCTFail("Could not read environment data from Backend.bundle"); return }

        XCTAssertEqual(environment.backendURL, URL(string: "https://prod-nginz-https.wire.com")!)
        XCTAssertEqual(environment.backendWSURL, URL(string: "https://prod-nginz-ssl.wire.com")!)
        XCTAssertEqual(environment.blackListURL, URL(string: "https://clientblacklist.wire.com/prod")!)
        XCTAssertEqual(environment.websiteURL, URL(string: "https://wire.com")!)
        XCTAssertEqual(environment.teamsURL, URL(string: "https://teams.wire.com")!)
        XCTAssertEqual(environment.accountsURL, URL(string: "https://accounts.wire.com")!)

    }
    
    func testThatWeCanLoadBackendTrust() {
        guard let environment = BackendEnvironment(userDefaults: defaults, configurationBundle: backendBundle) else { XCTFail("Could not read environment data from Backend.bundle"); return }
        
        guard let trust = environment.certificateTrust as? ServerCertificateTrust else {
            XCTFail(); return
        }
        
        XCTAssertEqual(trust.trustData.count, 1, "Should have one key")
        guard let data = trust.trustData.first else { XCTFail( ); return }
        
        let hosts = Set(data.hosts.map(\.value))
        XCTAssertEqual(hosts.count, 5)
        XCTAssertEqual(hosts, Set(["prod-nginz-https.wire.com", "prod-nginz-ssl.wire.com", "prod-assets.wire.com", "www.wire.com", "wire.com"]))        
    }
    
    func testThatWeCanWorkWithoutLoadingTrust() {
        EnvironmentType.staging.save(in: defaults)
        guard let environment = BackendEnvironment(userDefaults: defaults, configurationBundle: backendBundle) else { XCTFail("Could not read environment data from Backend.bundle"); return }
        
        guard let trust = environment.certificateTrust as? ServerCertificateTrust else {
            XCTFail(); return
        }
        
        XCTAssertEqual(trust.trustData.count, 0, "We should not have any keys")
    }
    
    func testThatWeCanSaveCustomBackendInfoToUserDefaults() {
        let configURL = URL(string: "example.com/config.json")!
        let baseURL = URL(string: "some.host.com")!
        let title = "Example"
        let endpoints = BackendEndpoints(
            backendURL: baseURL.appendingPathComponent("backend"),
            backendWSURL: baseURL.appendingPathComponent("backendWS"),
            blackListURL: baseURL.appendingPathComponent("blacklist"),
            teamsURL: baseURL.appendingPathComponent("teams"),
            accountsURL: baseURL.appendingPathComponent("accounts"),
            websiteURL: baseURL)
        let trust = ServerCertificateTrust(trustData: [])
        let environmentType = EnvironmentType.custom(url: configURL)
        let backendEnvironment = BackendEnvironment(title: title, environmentType: environmentType, endpoints: endpoints, certificateTrust: trust)
        
        backendEnvironment.save(in: defaults)
        
        let loaded = BackendEnvironment(userDefaults: defaults, configurationBundle: backendBundle)
        
        XCTAssertEqual(loaded?.endpoints.backendURL, endpoints.backendURL)
        XCTAssertEqual(loaded?.endpoints.backendWSURL, endpoints.backendWSURL)
        XCTAssertEqual(loaded?.endpoints.blackListURL, endpoints.blackListURL)
        XCTAssertEqual(loaded?.endpoints.teamsURL, endpoints.teamsURL)
        XCTAssertEqual(loaded?.endpoints.accountsURL, endpoints.accountsURL)
        XCTAssertEqual(loaded?.endpoints.websiteURL, endpoints.websiteURL)
        XCTAssertEqual(loaded?.title, title)
    }

}
