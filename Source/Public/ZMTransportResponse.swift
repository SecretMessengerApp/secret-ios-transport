////
//

import Foundation

extension ZMTransportResponse: SafeForLoggingStringConvertible {
    @objc public var safeForLoggingDescription: String {
        let errorDescription = transportSessionError?.localizedDescription
        let status = "status: \(httpStatus)"
        let dataSize = "size: \(self.rawData?.count ?? 0)"
        return "\(errorDescription ?? status) \(dataSize)"
    }
}
