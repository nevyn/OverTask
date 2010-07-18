//  Created by Joachim Bengtsson on 2010-07-16.

#import "OverTask_AppDelegate.h"
#import <Carbon/Carbon.h>

static EventHotKeyRef OTLeft, OTRight, OTUp, OTDown, OTReturn, OTAltUp, OTSpace;

@implementation OverTaskApp
enum {
	// NSEvent subtypes for hotkey events (undocumented).
	kEventHotKeyPressedSubtype = 6,
	kEventHotKeyReleasedSubtype = 9,
};

#pragma GCC push_options
#pragma GCC diagnostic ignored "-Wpointer-to-int-cast"

- (void)sendEvent:(NSEvent *)evt;
{
	if ([evt type] == NSSystemDefined && [evt subtype] ==kEventHotKeyPressedSubtype) {
		TaskView *tv = [(id)[self delegate] task];
    
    if(tv.isRenaming) return;
		
		if(evt.data1 == (int)OTLeft) [tv moveLeft:self];
		if(evt.data1 == (int)OTRight) [tv moveRight:self];
		if(evt.data1 == (int)OTUp) [tv moveUp:self];
		if(evt.data1 == (int)OTDown) [tv moveDown:self];
		if(evt.data1 == (int)OTReturn) [tv completeSelected:self];
		if(evt.data1 == (int)OTAltUp) [tv addChild:self];
		if(evt.data1 == (int)OTSpace) [tv renameSelected:self];
	}
	
	[super sendEvent:evt];
}
#pragma GCC pop_options
@end



@implementation OverTask_AppDelegate

@synthesize window, task;

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
#define test(x) if((s = (x)) != 0) { NSLog(@"Registration error: %d", s); return; }
	OSStatus s;
	EventHotKeyID nul;
	EventTargetRef t = GetApplicationEventTarget();
    test(RegisterEventHotKey(kVK_LeftArrow, cmdKey|controlKey, nul, t, 0, &OTLeft));
    test(RegisterEventHotKey(kVK_RightArrow, cmdKey|controlKey, nul, t, 0, &OTRight));
    test(RegisterEventHotKey(kVK_UpArrow, cmdKey|controlKey, nul, t, 0, &OTUp));
    test(RegisterEventHotKey(kVK_DownArrow, cmdKey|controlKey, nul, t, 0, &OTDown));
    test(RegisterEventHotKey(kVK_Return, cmdKey|controlKey, nul, t, 0, &OTReturn));
    test(RegisterEventHotKey(kVK_UpArrow, cmdKey|optionKey|controlKey, nul, t, 0, &OTAltUp));
    test(RegisterEventHotKey(kVK_Space, cmdKey|controlKey, nul, t, 0, &OTSpace));
#undef test
	
	
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
}
- (void)dealloc {

    [window release];
	
    [super dealloc];
}


@end
