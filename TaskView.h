//  Created by Joachim Bengtsson on 2010-07-16.

#import <Cocoa/Cocoa.h>

@class Node, TaskView;

@interface TaskView : NSView {
@public // for the intro
	Node *data;
	Node *selected;
	NSColor *colNormal, *colSelected, *colFocused;
	NSTextField *editor;
  void(^treeChanged)(TaskView*);
  NSMutableArray *focusStack;
}
@property (copy) void(^treeChanged)(TaskView*);
// I'd much, much, much rather have this class mirror a model
// tree with KVO, and have that model tree saved with CD,
// but I'd rather have this app working than pretty.
-(NSData*)treeData;
-(void)setupTreeWithData:(NSData*)data;

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
-(IBAction)focusSelected:(id)sender;
-(IBAction)unfocus:(id)sender;
-(IBAction)yank:(id)sender;

@property (readonly) BOOL isRenaming;
@end
