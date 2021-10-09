//
//


/// The following protocols are used in `UnauthenticatedTransportSession`
/// to enable easy injection of mocks in tests.

public protocol SessionProtocol {
    func task(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
        ) -> DataTaskProtocol
}

public protocol DataTaskProtocol {
    func resume()
}

// MARK: - Conformances

extension URLSessionDataTask: DataTaskProtocol {}

extension URLSession: SessionProtocol {

    public func task(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?
        ) -> Void) -> DataTaskProtocol {
        return dataTask(with: request, completionHandler: completionHandler) as DataTaskProtocol
    }
    
}
