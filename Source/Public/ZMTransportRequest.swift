//
//


import Foundation
import WireUtilities

extension String {
    fileprivate static let UUIDMatcher: NSRegularExpression = {
        let regex = try! NSRegularExpression(pattern: "[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}", options: .caseInsensitive)
        return regex
    }()
    
    fileprivate static let clientIDMatcher: NSRegularExpression = {
        let regex = try! NSRegularExpression(pattern: "[a-f0-9]{13,16}", options: .caseInsensitive)
        return regex
    }()
    
    fileprivate static let matchers = [UUIDMatcher, clientIDMatcher]

    var removingSensitiveInfo: String {
        let result = NSMutableString(string: self)
        let range = NSMakeRange(0, self.count)

        String.matchers
        .flatMap {
            $0.matches(in: self, options: [], range: range)
        }
        .reversed()
        .forEach {
            let matchedString = result.substring(with: $0.range)
            result.replaceCharacters(in: $0.range, with: matchedString.readableHash)
        }

        return result as String
    }
}

extension ZMTransportRequest: SafeForLoggingStringConvertible {
    @objc public var safeForLoggingDescription: String {
        let identifier = "\(Unmanaged.passUnretained(self).toOpaque())".readableHash
        return "<\(identifier)> \(ZMTransportRequest.string(for: self.method)) \(self.path.removingSensitiveInfo)"
    }
}
