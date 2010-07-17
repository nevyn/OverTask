//  Created by Joachim Bengtsson on 2010-07-17.

#import "NSTimer+blocks.h"

@interface NSObject (BlockInvoke)
-(void)tc_invoke;
@end
@implementation NSObject (BlockInvoke)
-(void)tc_invoke;
{
	void(^block)() = (void*)self;
	block();
}
@end

@implementation NSTimer (TCBlocks)
+ (NSTimer*)tc_timerWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo block:(void(^)())block;
{
	return [NSTimer timerWithTimeInterval:ti target:[[block copy] autorelease] selector:@selector(tc_invoke) userInfo:nil repeats:yesOrNo];
}
+ (NSTimer*)tc_scheduledTimerWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo block:(void(^)())block;
{
	return [NSTimer scheduledTimerWithTimeInterval:ti target:[[block copy] autorelease] selector:@selector(tc_invoke) userInfo:nil repeats:yesOrNo];
}
@end
