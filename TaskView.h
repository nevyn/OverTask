//  Created by Joachim Bengtsson on 2010-07-16.

#import <Cocoa/Cocoa.h>

@class Node;

@interface TaskView : NSView {
	Node *data;
	Node *selected;
	NSColor *border, *fill, *textColor;
	NSColor *selBorder, *selFill, *selTextColor;
	NSTextField *editor;
}
-(IBAction)moveLeft:(id)sender;
-(IBAction)moveRight:(id)sender;
-(IBAction)moveUp:(id)sender;
-(IBAction)moveDown:(id)sender;
-(IBAction)completeSelected:(id)sender;
-(IBAction)addSiblingLeft:(id)sender;
-(IBAction)addSiblingRight:(id)sender;
-(IBAction)addChild:(id)sender;
-(IBAction)renameSelected:(id)sender;
-(IBAction)doneRenamingSelected:(id)sender;

@property (readonly) BOOL isRenaming;
@end
