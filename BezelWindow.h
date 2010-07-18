//  Created by Joachim Bengtsson on 2010-07-18.

#import <Cocoa/Cocoa.h>

@class BezelView;
@interface BezelWindow : NSWindow {
	BezelView *bezel;
  NSTextField *text;
  NSTextField *textShadow;
}
+(BezelWindow*)fadeInWithMessage:(NSString*)message;
-(void)fadeOut;
@end
