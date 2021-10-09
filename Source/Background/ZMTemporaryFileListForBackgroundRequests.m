// 
// 


@import WireSystem;
#import "ZMTemporaryFileListForBackgroundRequests.h"
#import "ZMTaskIdentifierMap.h"

static NSString * const TemporaryDirectoryName = @"com.wire.zmessaging.ZMTemporaryFileListForBackgroundRequests";



@interface ZMTemporaryFileListForBackgroundRequests ()

@property (nonatomic, readonly) ZMTaskIdentifierMap *taskToTemporaryFile;

@end



@implementation ZMTemporaryFileListForBackgroundRequests

- (instancetype)init
{
    self = [super init];
    if(self) {
        _taskToTemporaryFile = [[ZMTaskIdentifierMap alloc] init];
    }
    return self;
}

- (NSURL *)temporaryFileWithBodyData:(NSData *)bodyData;
{
    static int counter;
    ++counter;
    
    NSError *error = nil;
    NSString *directoryPath = [NSString pathWithComponents:@[NSTemporaryDirectory(), TemporaryDirectoryName]];
    [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:@{} error:&error];
    
    NSString *filename = [NSString stringWithFormat:@"%d.bodydata", counter];
    NSURL *fileURL = [NSURL fileURLWithPath:directoryPath];
    fileURL = [fileURL URLByAppendingPathComponent:filename];
    
    BOOL success = [bodyData writeToURL:fileURL options:0 error:&error];
    if(!success) {
        ZMLogError(@"Failed to write payload to file %@: %@", fileURL.path, error);
        return nil;
    }
    
    return fileURL;
}

- (void)setTemporaryFile:(NSURL *)fileURL forTaskIdentifier:(NSUInteger)taskId;
{
    RequireString(self.taskToTemporaryFile[taskId] == nil, "Trying to create a temporary file for the same task twice");
    self.taskToTemporaryFile[taskId] = fileURL;
}

- (void)deleteFileForTaskID:(NSUInteger)taskId
{
    
    NSURL *temporaryFile = self.taskToTemporaryFile[taskId];
    if (temporaryFile != nil) {
        NSError *error;
        if (! [[NSFileManager defaultManager] removeItemAtURL:temporaryFile error:&error]) {
            ZMLogError(@"Unable to remove temporary body data file '%@': %@", temporaryFile.path, error);
        }
        [self.taskToTemporaryFile removeObjectForTaskIdentifier:taskId];
    }

}

@end
