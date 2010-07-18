//  Created by Joachim Bengtsson on 2010-07-18.

#import <Cocoa/Cocoa.h>
#import "TaskView.h"

struct OTIntroSteps;
@interface OTIntro : NSObject {
	TaskView *task;
  NSWindow *window;
  NSTimer *latestTimer;
  NSData *savedData;
  void(^savedCallback)(TaskView*);
}
@property (retain) TaskView *task;
@property (retain) NSWindow *window;
@property (retain) NSData *savedData;
@property (copy) void(^savedCallback)(TaskView*);
-run;
-cancel;
@end
