////
//

import Foundation
import WireSystem
import WireUtilities

extension BackgroundActivity: SafeForLoggingStringConvertible {
    public var safeForLoggingDescription: String {
        return "<BackgroundActivity [\(index)]: \(name.readableHash)>"
    }
}

struct ActivityName: SafeForLoggingStringConvertible {
    let name: String
    var safeForLoggingDescription: String {
        return name.readableHash
    }
}

