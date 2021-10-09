// 
// 


#import <Foundation/Foundation.h>
@import WireSystem;
@import WireUtilities;



@interface ZMExponentialBackoff : NSObject <TearDownCapable>

- (instancetype)initWithGroup:(ZMSDispatchGroup *)group workQueue:(NSOperationQueue *)workQueue;

/// Run the given block with exponential backoff.
///
/// This must be called on the workQueue, since the block will be executed synchronously when there's no wait. If there's a wait, the block will get enqueued onto the workQueue;
///
/// For each subsequent call an additional (exponentially growing) wait / delay will be inserted before running the block. If this method gets called while a block is already waiting, the waiting call 'wins' and the subsequent call will be ignored.
- (void)performBlock:(dispatch_block_t)block;

- (void)cancelAllBlocks;
- (void)tearDown; /// Must be called on the work queue

/// Resets the backoff such that the next call to -performBlock: will execute that block immediately.
- (void)resetBackoff;

- (void)reduceBackoff;
- (void)increaseBackoff;

/// This is exposed for testing.
@property (atomic) NSInteger maximumBackoffCounter;

@end
