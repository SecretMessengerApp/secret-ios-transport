//
//


import Foundation


public extension UUID {

    func transportString() -> String {
        return (self as NSUUID).transportString()
    }
}

extension Date {
    
    public func transportString() -> String {
        return (self as NSDate).transportString()
    }
}
