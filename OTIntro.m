//  Created by Joachim Bengtsson on 2010-07-18.

#import "OTIntro.h"
#import "BezelWindow.h"

	static BezelWindow *currentBezel;


@implementation OTIntro
@synthesize task, window, savedData, savedCallback;
-run
{
  static struct {
  	NSTimeInterval waitBefore;
  	void(^invocation)(OTIntro *self);
  	BOOL last;
	} steps[] = {
  	{0.0, ^ (OTIntro *self) {
    	currentBezel = [BezelWindow fadeInWithMessage:@"OverTask is for keeping track of a short-term hierarchical todo"
      @" while you code. Press ⌘-. at any time to abort this guide. Rerun from help menu at any time."];
    }},
    {7.0, ^ (OTIntro *self){
    	[currentBezel fadeOut]; currentBezel = nil;
    }},
    
    
  	{0.0, ^ (OTIntro *self) {
    	currentBezel = [BezelWindow fadeInWithMessage:@"Arrow keys navigate. Press ↑ to create a new task."];
    }},
    {2.0, ^ (OTIntro *self) {
    	[self.task moveUp:nil];
    }},
    {1.0, ^ (OTIntro *self) {
    	[self.task->editor setStringValue:@"Refactor saving > CoreData"];
    }},
    {0.5, ^ (OTIntro *self){
    	[currentBezel fadeOut]; currentBezel = nil;
    }},
    {1.5, ^ (OTIntro *self) {
    	[self.task doneRenamingSelected:nil];
    }},
    
    
  	{1.0, ^ (OTIntro *self) {
    	currentBezel = [BezelWindow fadeInWithMessage:@"← and → moves to or creates sibling tasks."];
    }},
    {2.0, ^ (OTIntro *self) {
    	[self.task moveLeft:nil];
    }},
    {1.0, ^ (OTIntro *self) {
    	[self.task->editor setStringValue:@"Add Sparke.framework"];
    }},
    {1.5, ^ (OTIntro *self) {
    	[self.task doneRenamingSelected:nil];
    }},
    
    {2.0, ^ (OTIntro *self) {
    	[self.task moveRight:nil];
    }},
    {0.75, ^ (OTIntro *self) {
    	[self.task moveRight:nil];
    }},
    {1.0, ^ (OTIntro *self) {
    	[self.task->editor setStringValue:@"Make intro sequence"];
    }},
    {1.5, ^ (OTIntro *self) {
    	[self.task doneRenamingSelected:nil];
    }},
    {0.5, ^ (OTIntro *self){
    	[currentBezel fadeOut]; currentBezel = nil;
    }},

    
   	{1.0, ^ (OTIntro *self) {
    	currentBezel = [BezelWindow fadeInWithMessage:@"↑ with a task selected creates child tasks."];
    }},
    {2.0, ^ (OTIntro *self) {
    	[self.task moveUp:nil];
    }},
    {1.0, ^ (OTIntro *self) {
    	[self.task->editor setStringValue:@"Nice message window"];
    }},
    {0.5, ^ (OTIntro *self){
    	[currentBezel fadeOut]; currentBezel = nil;
    }},
    {0.5, ^ (OTIntro *self) {
    	[self.task doneRenamingSelected:nil];
    }},
    {1.0, ^ (OTIntro *self) {
    	[self.task moveRight:nil];
    }},
    {1.0, ^ (OTIntro *self) {
    	[self.task->editor setStringValue:@"Sequenced actions"];
    }},
    {0.5, ^ (OTIntro *self) {
    	[self.task doneRenamingSelected:nil];
    }},
    {1.0, ^ (OTIntro *self) {
    	[self.task moveUp:nil];
    }},
    {1.0, ^ (OTIntro *self) {
    	[self.task->editor setStringValue:@"Block-based NSTimer"];
    }},
    {0.5, ^ (OTIntro *self) {
    	[self.task doneRenamingSelected:nil];
    }},
    
    {1.0, ^ (OTIntro *self) {
    	currentBezel = [BezelWindow fadeInWithMessage:@"Space or ⌫ completes a task and removes it."];
    }},
    {2.0, ^ (OTIntro *self) {
    	[self.task moveDown:nil];
    }},
    {0.75, ^ (OTIntro *self) {
    	[self.task moveDown:nil];
    }},
    {0.75, ^ (OTIntro *self) {
    	[self.task moveLeft:nil];
    }},
    {0.75, ^ (OTIntro *self) {
    	[self.task moveLeft:nil];
    }},
    {1.5, ^ (OTIntro *self) {
    	[self.task completeSelected:nil];
    }},
    {2.5, ^ (OTIntro *self) {
    	[self.task moveRight:nil];
    }},
    {0.5, ^ (OTIntro *self) {
    	[self.task moveUp:nil];
    }},
    {1.5, ^ (OTIntro *self) {
    	[self.task completeSelected:nil];
    }},
    
    
    {2.5, ^ (OTIntro *self){
    	[currentBezel fadeOut]; currentBezel = nil;
    }},
    
    {0.5, ^ (OTIntro *self) {
    	currentBezel = [BezelWindow fadeInWithMessage:@"⏎ edits the name of the current task."];
    }},
    {0.75, ^ (OTIntro *self) {
    	[self.task moveDown:nil];
    }},
    {0.75, ^ (OTIntro *self) {
    	[self.task moveLeft:nil];
    }},
    {1.5, ^ (OTIntro *self) {
    	[self.task renameSelected:nil];
    }},
    {1.0, ^ (OTIntro *self) {
    	[self.task->editor setStringValue:@"Refactor saving > JSON"];
    }},
    {0.5, ^ (OTIntro *self) {
    	[self.task doneRenamingSelected:nil];
    }},
    {0.5, ^ (OTIntro *self){
    	[currentBezel fadeOut]; currentBezel = nil;
    }},

    {0.5, ^ (OTIntro *self) {
    	currentBezel = [BezelWindow fadeInWithMessage:@"All of these tasks can be combined with ⌘-⌃ "
      @"to perform them while in any other app."];
    }},
    {1.0, ^ (OTIntro *self) {
    	[[NSWorkspace sharedWorkspace] launchApplication:@"Finder"];
    }},
    {1.75, ^ (OTIntro *self) {
    	[self.task moveRight:nil];
    }},
    {0.75, ^ (OTIntro *self) {
    	[self.task moveUp:nil];
    }},
    {1.5, ^ (OTIntro *self) {
    	[self.task completeSelected:nil];
    }},
    {0.5, ^ (OTIntro *self){
    	[currentBezel fadeOut]; currentBezel = nil;
    }},
    {0.5, ^ (OTIntro *self) {
    	currentBezel = [BezelWindow fadeInWithMessage:@"Finally, hold ⌘ and ⌃ while moving mouse up and down to adjust opacity."];
      __block float f = 0.0;
      [NSTimer tc_scheduledTimerWithTimeInterval:0.02 repeats:YES block:^(NSTimer *arg1) {
      	f += 0.8;
        self.window.alphaValue = (sin(f+M_PI/2.)+1.0)/2.0;
      	if(f > M_PI*4.5) {
	        self.window.alphaValue = 1.0;
        	[arg1 invalidate];
        }
      }];
    }},
    {2.5, ^ (OTIntro *self){
    	[currentBezel fadeOut]; currentBezel = nil;
    }},

    
    {0.5, ^ (OTIntro *self) {
    	currentBezel = [BezelWindow fadeInWithMessage:@"Enjoy!"];
    }},
    {1.5, ^ (OTIntro *self) {
    	[self.task completeSelected:nil];
    }},
    {1.0, ^ (OTIntro *self) {
    	[self.task completeSelected:nil];
    }},
    {0.1, ^ (OTIntro *self){
    	[currentBezel fadeOut]; currentBezel = nil;
    }},
    
    {0.0, ^ (OTIntro *self) {
    	[[NSWorkspace sharedWorkspace] launchApplication:@"OverTask"];
    }},


    
    {1.0, ^ (OTIntro *self) {
    	[self cancel];
    }},
    {0, 0, 1}
  };
  
  __block int i = 0;
  __block void(^stepper)(NSTimer *t);
  stepper = [[^ (NSTimer*t) {
  	steps[i].invocation(self);
    i++;
    if(steps[i].last) return;
	  latestTimer = [NSTimer tc_scheduledTimerWithTimeInterval:steps[i].waitBefore repeats:NO block:stepper];
  } copy] autorelease];
  stepper(nil);
  
  self.savedCallback = task.treeChanged;
  task.treeChanged = nil;
  self.savedData = [task treeData];
  [task setupTreeWithData:nil];
  
  return self;
}
-cancel
{
	[latestTimer invalidate]; latestTimer = nil;
  if(savedCallback) {
	  [task setupTreeWithData:self.savedData];
	  task.treeChanged = self.savedCallback;
  }
  self.task = self.window = nil;
  self.savedCallback = self.savedData = nil;
  
 	[currentBezel fadeOut]; currentBezel = nil;
  return self;
}
@end
