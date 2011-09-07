//  Created by Joachim Bengtsson on 2010-07-16.

#import <Cocoa/Cocoa.h>
#import "TaskView.h"
#import "OTIntro.h"

@interface OverTaskApp : NSApplication
@end

@interface OverTask_AppDelegate : NSObject 
{
	NSWindow *window;
	IBOutlet NSWindow *cheatSheet;
	    
	IBOutlet TaskView *task;

	
	OTIntro *intro;
}
@property (readonly) TaskView *task;
@property (nonatomic, retain) IBOutlet NSWindow *window;

-(IBAction)showIntro:(id)sender;
-(IBAction)cancelIntro:(id)sender;

@end
