//  Created by Joachim Bengtsson on 2010-07-16.

#import "FullscreenWindow.h"


@implementation FullscreenWindow
-(id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
	self = [super initWithContentRect:contentRect
							styleMask:NSBorderlessWindowMask
							  backing:bufferingType
								defer:flag];
	
	[self setLevel:NSScreenSaverWindowLevel];
	
	[self setFrame:[[NSScreen mainScreen] visibleFrame] display:YES];
	
	[self setIgnoresMouseEvents:YES];
	[self setBackgroundColor:[NSColor clearColor]];
	[self setOpaque:NO];
	[self setHasShadow:NO];
	
	return self;
}
-(BOOL)canBecomeKeyWindow;
{
	return YES;
}
@end
