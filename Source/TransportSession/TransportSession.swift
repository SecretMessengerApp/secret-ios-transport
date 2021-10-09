//
//

import Foundation

@objc
public protocol TransportSessionType: class, ZMBackgroundable, ZMRequestCancellation, TearDownCapable {
    
    var reachability: ReachabilityProvider & TearDownCapable { get }
    
    var pushChannel: ZMPushChannel { get }
    
    var cookieStorage: ZMPersistentCookieStorage { get }
    
    @objc(enqueueOneTimeRequest:) 
    func enqueueOneTime(_ request: ZMTransportRequest)
    
    @objc(attemptToEnqueueSyncRequestWithGenerator:)
    func attemptToEnqueueSyncRequest(generator: ZMTransportRequestGenerator) -> ZMTransportEnqueueResult
    
    @objc(setAccessTokenRenewalFailureHandler:)
    func setAccessTokenRenewalFailureHandler(handler: @escaping ZMCompletionHandlerBlock)
    
    func setNetworkStateDelegate(_ delegate: ZMNetworkStateDelegate?)
    
    @objc(addCompletionHandlerForBackgroundSessionWithIdentifier:handler:)
    func addCompletionHandlerForBackgroundSession(identifier: String, handler: @escaping () -> Void)
    
    @objc(configurePushChannelWithConsumer:groupQueue:)
    func configurePushChannel(consumer: ZMPushChannelConsumer, groupQueue: ZMSGroupQueue)
    
}

extension ZMTransportSession: TransportSessionType {}
