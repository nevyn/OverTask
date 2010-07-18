//  Created by Joachim Bengtsson on 2010-07-17.

#import <Cocoa/Cocoa.h>


@interface NSTimer (TCBlocks)
+ (NSTimer*)tc_timerWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo block:(void(^)(NSTimer*))block;
+ (NSTimer*)tc_scheduledTimerWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo block:(void(^)(NSTimer*))block;
@end
