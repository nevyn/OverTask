//  Created by Joachim Bengtsson on 2010-07-16.

#import "OverTask_AppDelegate.h"
#import <Carbon/Carbon.h>

#pragma GCC push_options
#pragma GCC diagnostic ignored "-Wpointer-to-int-cast"

struct {
  int key;
  void (^invocation)(id task);
  BOOL last;

  EventHotKeyRef keyref;
} OTKeys[] = {
	{kVK_LeftArrow, ^(id task){ [task moveLeft:nil]; } },
  {kVK_RightArrow, ^(id task){ [task moveRight:nil]; } },
  {kVK_UpArrow, ^(id task){ [task moveUp:nil]; } },
  {kVK_DownArrow, ^(id task){ [task moveDown:nil]; } },
  {kVK_Return, ^(id task){ [task renameSelected:nil]; } },
  {kVK_Delete, ^(id task){ [task completeSelected:nil]; } },
  {kVK_Space, ^(id task){ [task completeSelected:nil]; } },
  
  {0, NULL, YES}
};

@implementation OverTaskApp
enum {
	// NSEvent subtypes for hotkey events (undocumented).
	kEventHotKeyPressedSubtype = 6,
	kEventHotKeyReleasedSubtype = 9,
};


- (void)sendEvent:(NSEvent *)evt;
{
	if ([evt type] == NSSystemDefined && [evt subtype] ==kEventHotKeyPressedSubtype) {
		TaskView *tv = [(id)[self delegate] task];
    
    if(tv.isRenaming) return;
		
   	for(int i = 0; OTKeys[i].last != YES; i++) {
			if(evt.data1 == (int)OTKeys[i].keyref) {
      	OTKeys[i].invocation(tv);
        break;
      }
    }
	}
	
	[super sendEvent:evt];
}
@end

#pragma GCC pop_options


@implementation OverTask_AppDelegate

@synthesize window, task;
-(NSString*)appSupport;
{
	return [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"OverTask"];
}
-(NSString*)taskFile;
{
	return [[self appSupport] stringByAppendingPathComponent:@"tasks.overtask"];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
	OSStatus s;
	EventHotKeyID nul;
	EventTargetRef t = GetApplicationEventTarget();

	for(int i = 0; OTKeys[i].last != YES; i++) {
  	s = RegisterEventHotKey(OTKeys[i].key, cmdKey|controlKey, nul, t, 0, &OTKeys[i].keyref);
  	if(s != 0) { NSLog(@"Registration error: %d", s); }
  }	
	
	__block NSPoint oldPoint;
  __block NSTimer *mouseMonitor = nil;
  NSEvent*(^flagsHandler)(NSEvent*) = ^(NSEvent *evt) {
		NSUInteger newFlags = evt.modifierFlags & NSDeviceIndependentModifierFlagsMask;
		if(newFlags == (NSCommandKeyMask|NSControlKeyMask)) {
			oldPoint = NSEvent.mouseLocation;
      mouseMonitor = [NSTimer tc_scheduledTimerWithTimeInterval:0.01 repeats:YES block:^() {
        NSPoint newPoint = NSEvent.mouseLocation;
				
				float delta = newPoint.y - oldPoint.y;
        
				window.alphaValue = MAX(0.0, MIN(1.0, window.alphaValue + delta/150.));
				
				oldPoint = newPoint;
      }];
		} else if(mouseMonitor) {
      [mouseMonitor invalidate];
			mouseMonitor = nil;
		}
    return evt;
	};
	[NSEvent addGlobalMonitorForEventsMatchingMask:NSFlagsChangedMask handler:(void(^)(NSEvent*))flagsHandler];
  [NSEvent addLocalMonitorForEventsMatchingMask:NSFlagsChangedMask handler:flagsHandler];
  
  __block typeof(self) blself = self;
  task.treeChanged = ^ (TaskView *tv) {
  	[[tv treeData] writeToFile:blself.taskFile atomically:YES];
  };
  NSData *treeData = [NSData dataWithContentsOfFile:self.taskFile];
  if(treeData) [task setupTreeWithData:treeData];
}
- (void)dealloc {

    [window release];
	
    [super dealloc];
}


@end
