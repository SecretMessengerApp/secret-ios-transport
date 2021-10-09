//
//

import WireTransport

@objc class ZMMockURLSession: ZMURLSession {

    @objc var cancellationHandler: (() -> Void)? = nil

    @objc static func createMockSession() -> ZMMockURLSession {
        return ZMMockURLSession(configuration: .ephemeral, trustProvider: MockEnvironment(), delegate: ZMMockURLSessionDelegate(), delegateQueue: OperationQueue(), identifier: "ZMMockURLSession")
    }

    @objc(createMockSessionWithDelegate:)
    static func createMockSession(delegate: ZMURLSessionDelegate) -> ZMMockURLSession {
        return ZMMockURLSession(configuration: .ephemeral, trustProvider: MockEnvironment(), delegate: delegate, delegateQueue: OperationQueue(), identifier: "ZMMockURLSession")
    }

    override func cancelAllTasks(completionHandler handler: @escaping () -> Void) {
        super.cancelAllTasks {
            handler()
            self.cancellationHandler?()
        }
    }

}

// MARK: - Delegate

@objc class ZMMockURLSessionDelegate: NSObject, ZMURLSessionDelegate {

    func urlSession(_ URLSession: ZMURLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        // no-op
    }

    func urlSessionDidReceiveData(_ URLSession: ZMURLSession) {
        // no-op
    }
    
    func urlSession(_ URLSession: ZMURLSession, didDetectUnsafeConnectionToHost host: String) {
        // no-op
    }

    func urlSession(_ URLSession: ZMURLSession, taskDidComplete task: URLSessionTask, transportRequest: ZMTransportRequest, responseData: Data) {
        // no-op
    }

    func urlSessionDidFinishEvents(forBackgroundURLSession URLSession: ZMURLSession) {
        // no-op
    }

}
