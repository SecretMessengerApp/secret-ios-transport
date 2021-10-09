////
//

import Foundation

@objc public protocol URLSessionsDirectory: NSObjectProtocol {
    @objc var foregroundSession: ZMURLSession { get }
    @objc var backgroundSession: ZMURLSession { get }
    @objc var voipSession: ZMURLSession { get }
    @objc var allSessions: [ZMURLSession] { get }
}

@objcMembers public class CurrentURLSessionsDirectory: NSObject, URLSessionsDirectory {
    public var foregroundSession: ZMURLSession
    public var backgroundSession: ZMURLSession
    public var voipSession: ZMURLSession
    public var allSessions: [ZMURLSession] {
        return [foregroundSession, backgroundSession, voipSession]
    }

    @objc public init(foregroundSession: ZMURLSession, backgroundSession: ZMURLSession, voipSession: ZMURLSession) {
        self.foregroundSession = foregroundSession
        self.backgroundSession = backgroundSession
        self.voipSession = voipSession
    }
}

extension CurrentURLSessionsDirectory: TearDownCapable {
    public func tearDown() {
        foregroundSession.tearDown()
        backgroundSession.tearDown()
        voipSession.tearDown()
    }
}
