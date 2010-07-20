//  Created by Joachim Bengtsson on 2010-07-16.

#import "FullscreenWindow.h"

@interface FullscreenWindow ()
-(void)screensChanged;
@end


@implementation FullscreenWindow
-(id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
	self = [super initWithContentRect:contentRect
							styleMask:NSBorderlessWindowMask
							  backing:bufferingType
								defer:flag];
	
	[self setLevel:NSScreenSaverWindowLevel];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(screensChanged)
												 name:NSApplicationDidChangeScreenParametersNotification
											   object:nil];
	[self screensChanged];
	
	[self setIgnoresMouseEvents:YES];
	[self setBackgroundColor:[NSColor clearColor]];
	[self setOpaque:NO];
	[self setHasShadow:NO];
	
	return self;
}
-(void)dealloc;
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}
-(BOOL)canBecomeKeyWindow;
{
	return YES;
}
-(void)screensChanged;
{
	[self setFrame:[[[NSScreen screens] objectAtIndex:0] visibleFrame] display:YES];
}
@end
