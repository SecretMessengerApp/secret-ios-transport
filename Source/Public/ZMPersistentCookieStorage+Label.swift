//
//


import UIKit


@objcMembers public class CookieLabel: NSObject {

    private static var _label: CookieLabel?
    public static var _testOverrideLabel: CookieLabel?

    public private(set) var value: String

    public init(value: String) {
        self.value = value
        super.init()
    }

    private override convenience init() {
        self.init(value: UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString)
    }

    public var length: Int {
        return value.count
    }

    public static var current: CookieLabel {
        if let label = _testOverrideLabel {
            return label
        } else if let label = _label {
            return label
        } else {
            let label = CookieLabel()
            _label = label
            return label
        }
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? CookieLabel else { return false }
        return value == other.value
    }

}
