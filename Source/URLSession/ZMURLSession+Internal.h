// 
// 


#import "ZMURLSession.h"
@class ZMTemporaryFileListForBackgroundRequests;


@interface ZMURLSession (Tests)

@property (nonatomic) NSURLSession *backingSession;
@property (nonatomic) ZMTemporaryFileListForBackgroundRequests *temporaryFiles;

- (void)setRequest:(ZMTransportRequest *)request forTask:(NSURLSessionTask *)task;

@end
