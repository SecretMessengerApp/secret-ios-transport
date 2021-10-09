//
//

import UIKit

/**
 * A protocol for objects that can start and end background activities.
 */

@objc public protocol BackgroundActivityManager: NSObjectProtocol {
    /// Begin a background task.
    func beginBackgroundTask(withName name: String?, expirationHandler: (() -> Void)?) -> UIBackgroundTaskIdentifier

    /// End the background task.
    func endBackgroundTask(_ task: UIBackgroundTaskIdentifier)
    
    // Make sure to only access this from main thread!
    var backgroundTimeRemaining: TimeInterval { get }
    var applicationState: UIApplication.State { get }
}

extension BackgroundActivityManager {
    /// Returns application state and background time remaining
    /// This code should be called from main queue only!
    var stateDescription: String {
        if applicationState == .background {
            // Sometimes time remaining is very large even if we run in background
            let time = backgroundTimeRemaining > 100000 ? "No Limit" : String(format: "%.2f", backgroundTimeRemaining)
            return "App state: \(applicationState), time remaining: \(time)"
        } else {
            return "App state: \(applicationState)"
        }
    }
}

extension UIApplication.State: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .active:
            return "active"
        case .background:
            return "background"
        case .inactive:
            return "inactive"
        @unknown default:
            return "<uknown>"
        }
    }
}

extension UIApplication: BackgroundActivityManager {}
