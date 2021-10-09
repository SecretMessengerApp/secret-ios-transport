// 
// 


#import <Foundation/Foundation.h>

@interface ZMTemporaryFileListForBackgroundRequests : NSObject

- (NSURL *)temporaryFileWithBodyData:(NSData *)bodyData;
- (void)setTemporaryFile:(NSURL *)fileURL forTaskIdentifier:(NSUInteger)taskId;
- (void)deleteFileForTaskID:(NSUInteger)taskId;

@end
