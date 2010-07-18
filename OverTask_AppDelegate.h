//  Created by Joachim Bengtsson on 2010-07-16.

#import <Cocoa/Cocoa.h>
#import "TaskView.h"

@interface OverTaskApp : NSApplication
@end

@interface OverTask_AppDelegate : NSObject 
{
  NSWindow *window;
    
	IBOutlet TaskView *task;
}
@property (readonly) TaskView *task;
@property (nonatomic, retain) IBOutlet NSWindow *window;

@end
