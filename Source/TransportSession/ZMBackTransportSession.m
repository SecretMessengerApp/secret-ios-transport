//
//


@import WireSystem;
@import WireUtilities;
@import UIKit;

#import <WireTransport/WireTransport-Swift.h>

#import "ZMTransportSession+internal.h"
#import "ZMTransportCodec.h"
#import "ZMAccessToken.h"
#import "ZMTransportRequest+Internal.h"
#import "ZMPersistentCookieStorage.h"
#import "ZMPushChannelConnection.h"
#import "ZMTaskIdentifierMap.h"
#import "ZMReachability.h"
#import "Collections+ZMTSafeTypes.h"
#import "ZMTransportPushChannel.h"
#import "NSError+ZMTransportSession.h"
#import "ZMUserAgent.h"
#import "ZMURLSession.h"
#import <libkern/OSAtomic.h>
#import "ZMTLogging.h"
#import "NSData+Multipart.h"
#import "ZMTaskIdentifier.h"
#import "ZMBackTransportSession.h"


static NSString* ZMLogTag ZM_UNUSED = ZMT_LOG_TAG_NETWORK;

static NSString * const TaskTimerKey = @"task";
static NSString * const SessionTimerKey = @"session";
static NSInteger const DefaultMaximumRequests = 9999999;


@interface ZMBackTransportSession () <ZMAccessTokenHandlerDelegate, ZMTimerClient>

@property (nonatomic) Class pushChannelClass;
@property (nonatomic) BOOL applicationIsBackgrounded;
@property (nonatomic) BOOL shouldKeepWebsocketOpen;

@property (atomic) BOOL firstRequestFired;
//@property (nonatomic) NSURL *baseURL;
//@property (nonatomic) NSURL *websocketURL;
@property (nonatomic) id<BackendEnvironmentProvider> environment;
@property (nonatomic) NSOperationQueue *workQueue;
@property (nonatomic) ZMPersistentCookieStorage *cookieStorage;
@property (nonatomic) BOOL tornDown;
@property (nonatomic) NSString *applicationGroupIdentifier;
@property (nonatomic) ZMURLSession *session;

@property (nonatomic) ZMTransportPushChannel *transportPushChannel;

@property (nonatomic, weak) id<ZMPushChannelConsumer> pushChannelConsumer;
@property (nonatomic, weak) id<ZMSGroupQueue> pushChannelGroupQueue;


@property (nonatomic, copy, readonly) NSString *userAgentValue;

@property (nonatomic, readonly) ZMSDispatchGroup *workGroup;
@property (nonatomic, readonly) ZMTransportRequestScheduler *requestScheduler;

@property (nonatomic) ZMAccessTokenHandler *accessTokenHandler;

@property (nonatomic) NSMutableSet *expiredTasks;
@property (nonatomic, weak) id<ZMNetworkStateDelegate> weakNetworkStateDelegate;
@property (nonatomic) NSMutableDictionary <NSString *, dispatch_block_t> *completionHandlerBySessionID;

@property (nonatomic) id<RequestRecorder> requestLoopDetection;
@property (nonatomic, readwrite) id<ReachabilityProvider, TearDownCapable> reachability;
@property (nonatomic) id reachabilityObserverToken;
@property (nonatomic) ZMAtomicInteger *numberOfRequestsInProgress;

@property (nonatomic) NSMutableOrderedSet *prepareRequests;
@end

@implementation ZMBackTransportSession

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"You should not use -init" userInfo:nil];
    return [self initWithEnvironment:nil
                       cookieStorage:nil
                        reachability:nil
                  initialAccessToken:nil
          applicationGroupIdentifier:nil];
}

+ (void)setUpConfiguration:(NSURLSessionConfiguration *)configuration;
{
    configuration.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyNever;
    configuration.HTTPShouldUsePipelining = YES;
    configuration.HTTPMaximumConnectionsPerHost = 1;
    configuration.TLSMinimumSupportedProtocol = kTLSProtocol12;
    configuration.URLCache = nil;
}

+ (NSURLSessionConfiguration *)foregroundSessionConfiguration
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    configuration.timeoutIntervalForRequest = 60;
    configuration.timeoutIntervalForResource = 12 * 60;
    [self setUpConfiguration:configuration];
    return configuration;
}

+ (NSString *)identifierWithPrefix:(NSString *)prefix userIdentifier:(NSUUID *)userIdentifier
{
    return [NSString stringWithFormat:@"%@-%@", prefix, userIdentifier.transportString];
}

- (instancetype)initWithEnvironment:(id<BackendEnvironmentProvider>)environment
                      cookieStorage:(ZMPersistentCookieStorage *)cookieStorage
                       reachability:(id<ReachabilityProvider, TearDownCapable>)reachability
                 initialAccessToken:(ZMAccessToken *)initialAccessToken
         applicationGroupIdentifier:(NSString *)applicationGroupIdentifier
{
    NSUUID *userIdentifier = cookieStorage.userIdentifier;
    NSOperationQueue *queue = [NSOperationQueue zm_serialQueueWithName:[ZMBackTransportSession identifierWithPrefix:@"ZMBackTransportSession" userIdentifier:userIdentifier]];
    ZMSDispatchGroup *group = [ZMSDispatchGroup groupWithLabel:[ZMBackTransportSession identifierWithPrefix:@"ZMBackTransportSession init" userIdentifier:userIdentifier]];
    NSString *identifier = [ZMBackTransportSession identifierWithPrefix:ZMURLSessionForegroundIdentifier userIdentifier:userIdentifier];
    
    ZMURLSession *backgroundSession = [[ZMURLSession alloc] initWithConfiguration:[ZMBackTransportSession foregroundSessionConfiguration] trustProvider:environment delegate: self delegateQueue:queue identifier:identifier];

    ZMTransportRequestScheduler *scheduler = [[ZMTransportRequestScheduler alloc] initWithSession:self operationQueue:queue group:group reachability:reachability];

    return [self initWithURLSession: backgroundSession
                         requestScheduler:scheduler
                             reachability:reachability
                                    queue:queue
                                    group:group
                             environment:environment
                            cookieStorage:cookieStorage
                       initialAccessToken:initialAccessToken];
}

- (instancetype)initWithURLSession:(ZMURLSession *)session
                        requestScheduler:(ZMTransportRequestScheduler *)requestScheduler
                            reachability:(id<ReachabilityProvider, TearDownCapable>)reachability
                                   queue:(NSOperationQueue *)queue
                                   group:(ZMSDispatchGroup *)group
                             environment:(id<BackendEnvironmentProvider>)environment
                           cookieStorage:(ZMPersistentCookieStorage *)cookieStorage
                      initialAccessToken:(ZMAccessToken *)initialAccessToken
{
    return [self initWithURLSession:session
                         requestScheduler:requestScheduler
                             reachability:reachability
                                    queue:queue
                                    group:group
                             environment:environment
                         pushChannelClass:nil
                            cookieStorage:cookieStorage
                       initialAccessToken:initialAccessToken];
}


- (instancetype)initWithURLSession:(ZMURLSession *)session
                        requestScheduler:(ZMTransportRequestScheduler *)requestScheduler
                            reachability:(id<ReachabilityProvider, TearDownCapable>)reachability
                                   queue:(NSOperationQueue *)queue
                                   group:(ZMSDispatchGroup *)group
                             environment:(id<BackendEnvironmentProvider>)environment
                        pushChannelClass:(Class)pushChannelClass
                           cookieStorage:(ZMPersistentCookieStorage *)cookieStorage
                      initialAccessToken:(ZMAccessToken *)initialAccessToken
{
    self = [super init];
    if (self) {
        self.environment = environment;
        self.baseURL = environment.backendURL;
        self.websocketURL = environment.backendWSURL;
        self.numberOfRequestsInProgress = [[ZMAtomicInteger alloc] initWithInteger:0];
        self.prepareRequests = [NSMutableOrderedSet orderedSet];
        
        self.workQueue = queue;
        _workGroup = group;
        self.cookieStorage = cookieStorage;
        self.expiredTasks = [NSMutableSet set];
        self.completionHandlerBySessionID = [NSMutableDictionary new];
        
        self.session = session;
        
        _requestScheduler = requestScheduler;
        self.reachability = reachability;
        self.requestScheduler.schedulerState = ZMTransportRequestSchedulerStateNormal;
        
        self.maximumConcurrentRequests = DefaultMaximumRequests;
        
        self.firstRequestFired = NO;
        if (pushChannelClass == nil) {
            pushChannelClass = ZMTransportPushChannel.class;
        }
        self.transportPushChannel = [[pushChannelClass alloc] initWithScheduler:self.requestScheduler userAgentString:[ZMUserAgent userAgentValue] environment:environment];
        self.accessTokenHandler = [[ZMAccessTokenHandler alloc] initWithBaseURL:self.baseURL
                                                                  cookieStorage:self.cookieStorage
                                                                       delegate:self
                                                                          queue:queue
                                                                          group:group
                                                                        backoff:nil
                                                             initialAccessToken:initialAccessToken];
        ZM_WEAK(self);
        self.requestLoopDetection = [[RequestLoopDetection alloc] initWithTriggerCallback:^(NSString * _Nonnull path) {
            ZM_STRONG(self);
            if(self.requestLoopDetectionCallback != nil) {
                self.requestLoopDetectionCallback(path);
            }
        }];
    }
    return self;
}

- (void)tearDown
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.tornDown = YES;
    
    self.reachabilityObserverToken = nil;
    [self.transportPushChannel closeAndRemoveConsumer];
    [self.workGroup enter];
    [self.workQueue addOperationWithBlock:^{
        [self.session tearDown];
        [self.workGroup leave];
    }];
}

#if DEBUG
- (void)dealloc
{
    NSLog(@"ZMBackTransportSession deinit");
    RequireString(self.tornDown, "Did not call tearDown on %p", (__bridge void *) self);
}
#endif

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p> %@ / %@",
            self.class, self,
            self.baseURL, self.websocketURL];
}

- (void)setAccessTokenRenewalFailureHandler:(ZMCompletionHandlerBlock)handler;
{
    [self.accessTokenHandler setAccessTokenRenewalFailureHandler:handler];

}

- (void)setAccessTokenRenewalSuccessHandler:(ZMAccessTokenHandlerBlock)handler
{
    [self.accessTokenHandler setAccessTokenRenewalSuccessHandler:handler];
}

- (ZMAccessToken *)accessToken {
    return self.accessTokenHandler.accessToken;
}

- (NSString *)tasksDescription;
{
    return self.session.description;
}

- (void)addCompletionHandlerForBackgroundSessionWithIdentifier:(NSString *)identifier handler:(dispatch_block_t)handler;
{
    self.completionHandlerBySessionID[identifier] = [handler copy];
}

- (void)getBackgroundTasksWithCompletionHandler:(void (^)(NSArray <NSURLSessionTask *>*))completionHandler;
{
    [self.session getTasksWithCompletionHandler:completionHandler];
}

- (void)enqueueOneTimeRequest:(ZMTransportRequest *)searchRequest;
{
    [self.numberOfRequestsInProgress increment];
    [self enqueueTransportRequest:searchRequest];
}

- (ZMTransportEnqueueResult *)attemptToEnqueueSyncRequestWithGenerator:(NS_NOESCAPE ZMTransportRequestGenerator)requestGenerator;
{
    //
    // N.B.: This method needs to be thread safe!
    //
    if (self.tornDown) {
        return [ZMTransportEnqueueResult resultDidHaveLessRequestsThanMax:NO didGenerateNonNullRequest:NO];
    }
    self.firstRequestFired = YES;
    
    NSInteger const limit = MIN(self.maximumConcurrentRequests, self.requestScheduler.concurrentRequestCountLimit);
    NSInteger const newCount = [self.numberOfRequestsInProgress increment];
    if (limit < newCount) {
        ZMLogInfo(@"Reached limit of %ld concurrent requests. Not enqueueing.", (long)limit);
        ZMTransportRequest *request = requestGenerator();
        if (request != nil) {
            if ([request.path containsString:@"v3"] && request.method == ZMMethodGET) {
                [self.prepareRequests addObject:request];
            } else {
                [self.prepareRequests insertObject:request atIndex:0];
            }
        }
        return [ZMTransportEnqueueResult resultDidHaveLessRequestsThanMax:NO didGenerateNonNullRequest:NO];
    } else {
        ZMTransportRequest *generateRequest = requestGenerator();
        if (generateRequest) {
            [self enqueueTransportRequest:generateRequest];
            return [ZMTransportEnqueueResult resultDidHaveLessRequestsThanMax:YES didGenerateNonNullRequest:YES];
        }
        ZMTransportRequest *prepareRequest = [self.prepareRequests firstObject];
        if (prepareRequest) {
            [self.prepareRequests removeObject:prepareRequest];
            [self enqueueTransportRequest:prepareRequest];
            return [ZMTransportEnqueueResult resultDidHaveLessRequestsThanMax:YES didGenerateNonNullRequest:YES];
        }
        return [ZMTransportEnqueueResult resultDidHaveLessRequestsThanMax:YES didGenerateNonNullRequest:NO];
    }
}

- (void)enqueueTransportRequest:(ZMTransportRequest *)request;
{
    //
    // N.B.: This part of the method needs to be thread safe!
    //
    [request startBackgroundActivity];
    RequireString(request.hasRequiredPayload, "Payload vs. method");
    
    ZM_WEAK(self);
    ZMSDispatchGroup *group = self.workGroup;
    [group enter];
    [self.workQueue addOperationWithBlock:^{
        ZM_STRONG(self);
        [self.requestScheduler addItem:request];
        [group leave];
    }];
}

- (void)sendTransportRequest:(ZMTransportRequest *)request;
{
    NSDate * const expirationDate = request.expirationDate;
    
    // Immediately fail request if it has already expired at this point in time
    if ((expirationDate != nil) && (expirationDate.timeIntervalSinceNow < 0.1)) {
        NSError *error = [NSError errorWithDomain:ZMTransportSessionErrorDomain code:ZMTransportSessionErrorCodeRequestExpired userInfo:nil];
        ZMTransportResponse *expiredResponse = [ZMTransportResponse responseWithTransportSessionError:error];
        [request completeWithResponse:expiredResponse];
        return;
    }
    
    // TODO: Need to set up a timer such that we can fail expired requests before they hit this point of the code -> namely when offline
    
    ZMURLSession *session = self.session;
    if (session.configuration.timeoutIntervalForRequest < expirationDate.timeIntervalSinceNow) {
        ZMLogWarn(@"May not be able to time out request. timeoutIntervalForRequest (%g) is too low (%g).",
                  session.configuration.timeoutIntervalForRequest, expirationDate.timeIntervalSinceNow);
    }
    
    NSURLSessionTask *task = [self suspendedTaskForRequest:request onSession:session];
    if (expirationDate) { //TODO can we test this if-statement somehow?
        [self startTimeoutForTask:task date:expirationDate onSession:session];
    }
    
    [request markStartOfUploadTimestamp];
    [task resume];
    [self.requestLoopDetection recordRequestWithPath:request.path contentHash:request.contentDebugInformationHash date:nil];
}

- (NSURLSessionTask *)suspendedTaskForRequest:(ZMTransportRequest *)request onSession:(ZMURLSession *)session;
{
    NSURL *baseURL = self.baseURL;

    if ([request.path isEqualToString:@"/self/ipproxy"]) {
        baseURL = self.environment.backendURL;
    }
    NSURL *url = [NSURL URLWithString:request.path relativeToURL:baseURL];
    NSAssert(url != nil, @"Nil URL in request");
    
    NSMutableURLRequest *URLRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [URLRequest configureWithRequest:request];
    [request setTimeoutIntervalOnRequestIfNeeded:URLRequest
                       applicationIsBackgrounded:self.applicationIsBackgrounded
                          usingBackgroundSession:session.isBackgroundSession];
    
    [self.accessTokenHandler checkIfRequest:request needsToFetchAccessTokenInURLRequest:URLRequest];
    
    NSData *bodyData = URLRequest.HTTPBody;
    URLRequest.HTTPBody = nil;
    ZMLogPublic(@"Request: %@", request.safeForLoggingDescription);
    ZMLogInfo(@"----> Request: %@\n%@", URLRequest.allHTTPHeaderFields, request);
    NSURLSessionTask *task = [session taskWithRequest:URLRequest bodyData:(bodyData.length == 0) ? nil : bodyData transportRequest:request];
    return task;
}

- (void)startTimeoutForTask:(NSURLSessionTask *)task date:(NSDate *)date onSession:(ZMURLSession *)session
{
    ZMTimer *timer = [ZMTimer timerWithTarget:self operationQueue:self.workQueue];
    timer.userInfo = @{
                       TaskTimerKey: task,
                       SessionTimerKey: session
                       };
    
    [session setTimeoutTimer:timer forTask:task];
    
    [timer fireAtDate:date];
}


- (void)timerDidFire:(ZMTimer *)timer
{
    NSURLSessionTask *task = timer.userInfo[TaskTimerKey];
    ZMURLSession *session = timer.userInfo[SessionTimerKey];
    [self expireTask:task session:session];
}

- (void)expireTask:(NSURLSessionTask *)task session:(ZMURLSession *)session;
{
    ZMLogDebug(@"Expiring task %lu", (unsigned long) task.taskIdentifier);
    [self.expiredTasks addObject:task]; // Need to make sure it's set before cancelling.
    [session cancelTaskWithIdentifier:task.taskIdentifier completionHandler:^(BOOL didCancel){
        if (! didCancel) {
            ZMLogDebug(@"Removing expired task %lu", (unsigned long) task.taskIdentifier);
            [self.expiredTasks removeObject:task];
        }
    }];
}

- (void)didCompleteRequest:(ZMTransportRequest *)request data:(NSData *)data task:(NSURLSessionTask *)task error:(NSError *)error session:(ZMURLSession *)session;
{
    NSHTTPURLResponse *httpResponse = (id) task.response;
    
    BOOL const expired = [self.expiredTasks containsObject:task];
    ZMLogDebug(@"Task %lu is %@", (unsigned long) task.taskIdentifier, expired ? @"expired" : @"NOT expired");
    if (task.error != nil) {
        ZMLogDebug(@"Task %lu finished with error: %@", (unsigned long) task.taskIdentifier, task.error.description);
    }
    NSError *transportError = [NSError transportErrorFromURLTask:task expired:expired];
    ZMTransportResponse *response = [self transportResponseFromURLResponse:httpResponse data:data error:transportError];
    ZMLogPublic(@"Response to %@: %@", request.safeForLoggingDescription,  response.safeForLoggingDescription);
    ZMLogInfo(@"<---- Response to %@ %@ (status %u): %@", [ZMTransportRequest stringForMethod:request.method], request.path, (unsigned) httpResponse.statusCode, response);
    ZMLogInfo(@"URL Session is %@", session.description);
    if (response.result == ZMTransportResponseStatusExpired) {
        [request completeWithResponse:response];
        return;
    }
    
    if (request.responseWillContainAccessToken) {
        [self.accessTokenHandler processAccessTokenResponse:response];
    }
    
    // If this requests needed authentication, but the access token wasn't valid, fail it:
    if (request.needsAuthentication && (httpResponse.statusCode == 401)) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Request requiring authentication finished with 404 response. Make sure there is an access token."};
        NSError *tryAgainError = [NSError tryAgainLaterErrorWithUserInfo:userInfo];
        ZMTransportResponse *tryAgainResponse = [ZMTransportResponse responseWithTransportSessionError:tryAgainError];
        [request completeWithResponse:tryAgainResponse];
    } else {
        [request completeWithResponse:response];
    }
}


- (ZMTransportResponse *)transportResponseFromURLResponse:(NSURLResponse *)URLResponse data:(NSData *)data error:(NSError *)error;
{
    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *) URLResponse;
    return [[ZMTransportResponse alloc] initWithHTTPURLResponse:HTTPResponse data:data error:error];
}

- (void)processCookieResponse:(NSHTTPURLResponse *)HTTPResponse;
{
    [self.cookieStorage setCookieDataFromResponse:HTTPResponse forURL:HTTPResponse.URL];
}

- (void)handlerDidReceiveAccessToken:(ZMAccessTokenHandler *)handler
{
    NOT_USED(handler);
    [self.requestScheduler sessionDidReceiveAccessToken:self];
    
    self.transportPushChannel.accessToken = self.accessToken;
}

- (void)handlerDidClearAccessToken:(ZMAccessTokenHandler *)handler
{
    NOT_USED(handler);
    self.transportPushChannel.accessToken = nil;
}

- (void)prepareForSuspendedState;
{
}

@end

@implementation ZMBackTransportSession (RequestCancellation)

- (void)cancelTaskWithIdentifier:(ZMTaskIdentifier *)identifier;
{

}

@end

@implementation ZMBackTransportSession (RequestScheduler)

@dynamic reachability;

- (void)sendAccessTokenRequest;
{
    [self.accessTokenHandler sendAccessTokenRequestWithURLSession:self.session];
}

- (BOOL)accessTokenIsAboutToExpire {
    return [self.accessTokenHandler accessTokenIsAboutToExpire];
}

- (BOOL)canStartRequestWithAccessToken;
{
    return [self.accessTokenHandler canStartRequestWithAccessToken];
}


- (void)sendSchedulerItem:(id<ZMTransportRequestSchedulerItemAsRequest>)item;
{
    [self sendTransportRequest:item.transportRequest];
}

- (void)temporarilyRejectSchedulerItem:(id<ZMTransportRequestSchedulerItemAsRequest>)item;
{
    
}

- (void)schedulerIncreasedMaximumNumberOfConcurrentRequests:(ZMTransportRequestScheduler *)scheduler;
{

}

- (void)schedulerWentOffline:(ZMTransportRequestScheduler *)scheduler
{

}

@end


@implementation ZMBackTransportSession (URLSessionDelegate)

- (void)URLSession:(ZMURLSession *)URLSession dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler;
{
    NOT_USED(URLSession);
    NOT_USED(dataTask);
    // Forward the response to the request scheduler:
    NSHTTPURLResponse * const HTTPResponse = (id) response;
    [self.requestScheduler processCompletedURLResponse:HTTPResponse URLError:nil];
    // Continue the task:
    completionHandler(NSURLSessionResponseAllow);
    
}

- (void)URLSessionDidReceiveData:(ZMURLSession *)URLSession;
{
    NOT_USED(URLSession);
}

- (void)URLSession:(ZMURLSession *)URLSession taskDidComplete:(NSURLSessionTask *)task transportRequest:(ZMTransportRequest *)request responseData:(NSData *)data;
{
    NSTimeInterval timeDiff = -[request.startOfUploadTimestamp timeIntervalSinceNow];
    ZMLogDebug(@"(Almost) bare network time for request %p %@ %@: %@s", request, request.methodAsString, request.path, @(timeDiff));
    NSError *error = task.error;
    NSHTTPURLResponse *HTTPResponse = (id)task.response;
    [self processCookieResponse:HTTPResponse];

    BOOL didConsume = [self.accessTokenHandler consumeRequestWithTask:task data:data session:URLSession shouldRetry:self.requestScheduler.canSendRequests];
    if (!didConsume) {
        [self didCompleteRequest:request data:data task:task error:error session:URLSession];
    }
    
    [self.requestScheduler processCompletedURLTask:task];
    [self.expiredTasks removeObject:task];
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(ZMURLSession *)URLSession
{
    NSString *identifier = URLSession.configuration.identifier;
    dispatch_block_t storedHandler = [self.completionHandlerBySessionID[identifier] copy];
    self.completionHandlerBySessionID[identifier] = nil;
    
    if (nil != storedHandler) {
        ZMLogDebug(@"-- <%@ %p> %@ -> calling background event completion handler for session: %@", self.class, self, NSStringFromSelector(_cmd), identifier);
        dispatch_async(dispatch_get_main_queue(), ^{
            storedHandler();
        });
    } else {
        ZMLogDebug(@"-- <%@ %p> %@ -> No stored completion handler found for session: %@", self.class, self, NSStringFromSelector(_cmd), identifier);
    }
}

- (void)URLSession:(ZMURLSession *)URLSession didDetectUnsafeConnectionToHost:(NSString *)host
{
    NOT_USED(URLSession);
    
    ZMLogDebug(@"Detected unsafe connection to %@", host);
    [self.requestScheduler setSchedulerState:ZMTransportRequestSchedulerStateOffline];
    [self.weakNetworkStateDelegate didGoOffline];
}

@end
