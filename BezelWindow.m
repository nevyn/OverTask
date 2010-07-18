//  Created by Joachim Bengtsson on 2010-07-18.

#import "BezelWindow.h"

@interface BezelView : NSView
@end
@implementation BezelView
-(void)drawRect:(NSRect)r;
{
	NSBezierPath *bzp = [NSBezierPath bezierPathWithRoundedRect:(NSRect){.size=self.frame.size}
                                                      xRadius:20
                                                      yRadius:20];
  [[NSColor colorWithCalibratedWhite:0.1 alpha:0.6] set];
  [bzp fill];
}
@end



@implementation BezelWindow
- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag;
{
	self = [super initWithContentRect:contentRect
                          styleMask:NSBorderlessWindowMask
                            backing:bufferingType
                              defer:flag];
  if(!self) return nil;
  
	[self setLevel:NSScreenSaverWindowLevel];
	[self setIgnoresMouseEvents:YES];
	[self setBackgroundColor:[NSColor clearColor]];
	[self setOpaque:NO];
	[self setHasShadow:NO];

	NSRect pen = (NSRect){.size=contentRect.size};
  bezel = [[BezelView alloc] initWithFrame:pen];
  [self.contentView addSubview:bezel];
  pen = NSInsetRect(pen, 10, 10);
  text = [[NSTextField alloc] initWithFrame:pen];
  text.font = [NSFont systemFontOfSize:42];
  text.textColor = [NSColor colorWithCalibratedWhite:1.0 alpha:0.9];
  [text setEditable:NO];
  [text setBordered:NO];
  [text setDrawsBackground:NO];
  [self.contentView addSubview:text];
  
  pen.origin.y -= 1;
  textShadow = [[NSTextField alloc] initWithFrame:pen];
  textShadow.font = [NSFont systemFontOfSize:42];
  textShadow.textColor = [NSColor colorWithCalibratedWhite:0.0 alpha:0.9];
  [textShadow setEditable:NO];
  [textShadow setBordered:NO];
  [textShadow setDrawsBackground:NO];
  [self.contentView addSubview:textShadow positioned:NSWindowBelow relativeTo:text];

  
  return self;
}
-(void)dealloc;
{
	[bezel release];
  [text release];
  [textShadow release];
  [super dealloc];
}
+(BezelWindow*)fadeInWithMessage:(NSString*)message;
{
  NSRect fr = [NSScreen mainScreen].visibleFrame;
  fr.origin = NSZeroPoint;
  fr.size.height = 200;
  fr.size.width -= 20;
	BezelWindow *w = [[BezelWindow alloc] initWithContentRect:fr 
                                                   styleMask:0
                                                     backing:NSBackingStoreBuffered
                                                       defer:NO];
  fr.origin.y = [NSScreen mainScreen].frame.size.height-32;
  fr.origin.x = 10;
  
  [w setFrameTopLeftPoint:fr.origin];
  
  w.alphaValue = 0.0;
  [NSTimer tc_scheduledTimerWithTimeInterval:0.02 repeats:YES block:^ (NSTimer*t) {
  	if(w.alphaValue < 0.99)
    	w.alphaValue += 0.08;
    else {
    	w.alphaValue = 1.0;
      [t invalidate];
    }
  }];

  
  [w orderFrontRegardless];
  w->text.stringValue = message;
  w->textShadow.stringValue = message;
  

  return w;
}
-(void)fadeOut;
{
	[NSTimer tc_scheduledTimerWithTimeInterval:0.02 repeats:YES block:^ (NSTimer*t) {
  	if(self.alphaValue > 0.01)
    	self.alphaValue -= 0.08;
    else {
    	[self close];
      [t invalidate];
    }
  }];
}
@end
