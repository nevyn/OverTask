//  Created by Joachim Bengtsson on 2010-07-16.

float frand() {
	return (rand()%10000)/10000.f;
}

#import "TaskView.h"

@interface Node : NSObject
{
	Node *parent;
	NSString *name;
	NSMutableArray *children;
	NSColor *laneColor;
	NSColor *selLaneColor;
	CGRect frame;
}
@property (copy) NSString *name;
@property (assign) Node *parent;
@property (retain) NSColor *laneColor;
@property (retain) NSColor *selLaneColor;
@property CGRect frame;
@end
@implementation Node
@synthesize name, parent, laneColor, selLaneColor, frame;
-(id)initWithName:(NSString *)name_ children:(NSArray*)children_;
{
	name = [name_ copy];
	children = [NSMutableArray new];
	for (Node *child in children_)
		[[self mutableArrayValueForKey:@"children"] addObject:child];
	
	/*float r = frand(), g = frand(), b = frand();
	laneColor = [[NSColor colorWithCalibratedRed:r green:g blue:b alpha:0.1] retain];
	selLaneColor = [[NSColor colorWithCalibratedRed:r green:g blue:b alpha:0.2] retain];*/
	
	return self;
}
+(id)nodeWithName:(NSString *)name_ children:(NSArray*)children_;
{
	return [[[self class] alloc] initWithName:name_ children:children_];
}
-(Node*)objectInChildrenAtIndex:(NSInteger)index;
{
	return [children objectAtIndex:index];
}
-(NSInteger)countOfChildren;
{
	return [children count];
}
-(void)insertObject:(Node*)child inChildrenAtIndex:(NSInteger)index;
{
	[children insertObject:child atIndex:index];
	child.parent = self;
}
-(void)removeObjectFromChildrenAtIndex:(NSInteger)index;
{
	[children removeObjectAtIndex:index];
}
-(NSArray*)children; { return children; }
-(void)dealloc; {
	[name release]; [children release];
	[laneColor release]; [selLaneColor release];
	[super dealloc];
}
@end




@implementation TaskView

- (id)initWithFrame:(NSRect)frame {
    if(![super initWithFrame:frame]) return nil;
	
	data = [[Node nodeWithName:nil children:[NSArray arrayWithObjects:
		[Node nodeWithName:@"Task A" children:[NSArray arrayWithObjects:
			[Node nodeWithName:@"Task A.1" children:nil],
			[Node nodeWithName:@"Task A.2" children:nil],
			nil
		]],
		[Node nodeWithName:@"Task B" children:nil],
		nil
	]] retain];
	
	selected = [[[data.children objectAtIndex:0] children] objectAtIndex:1];
	
	fill = [[NSColor colorWithCalibratedRed:0.475 green:0.863 blue:0.492 alpha:0.2] retain];
	border = [[NSColor colorWithCalibratedRed:0.284 green:0.611 blue:0.306 alpha:0.2] retain];
	textColor = [[NSColor colorWithCalibratedRed:0.156 green:0.317 blue:0.166 alpha:0.6] retain];
	
	selFill = [[NSColor colorWithCalibratedRed:0.475 green:0.863 blue:0.492 alpha:0.8] retain];
	selBorder = [[NSColor colorWithCalibratedRed:0.284 green:0.611 blue:0.306 alpha:0.8] retain];
	selTextColor = [[NSColor colorWithCalibratedRed:0.156 green:0.317 blue:0.166 alpha:0.8] retain];
	
    return self;
}

static const CGFloat kTVHeight = 200;

- (void)drawNode:(Node*)node inRect:(CGRect)f;
{
	CGRect laneR = f;
	laneR.size.height = self.frame.size.height - laneR.origin.y;
	[border set];
	[[NSBezierPath bezierPathWithRect:laneR] stroke];
	
	CGRect r = CGRectInset(f, 10, 10);
	NSBezierPath *bzp = [NSBezierPath bezierPathWithRoundedRect:r xRadius:0 yRadius:0];
	[node==selected?selFill:fill set];
	[bzp fill];

	[node==selected?selBorder:border set];
	[bzp stroke];

	NSMutableParagraphStyle *centered = [[[NSMutableParagraphStyle alloc] init] autorelease];
	centered.alignment = NSCenterTextAlignment;
	
	CGRect textR = r;
	textR.size.height -= textR.size.height/2. - [[node name] sizeWithAttributes:nil].height;
	
	[[node name] drawInRect:textR withAttributes:$dict(
		NSParagraphStyleAttributeName, centered,
		NSForegroundColorAttributeName, node==selected?selTextColor:textColor,
		NSFontAttributeName, [NSFont systemFontOfSize:20],
	)];
	
	CGFloat w = f.size.width/node.children.count;
	CGRect pen = f;
	pen.size.width = w;
	pen.origin.y += f.size.height;
	
	node.frame = r;
	
	for (Node *n in node.children) {
		[self drawNode:n inRect:pen];
		pen.origin.x += w;
	}
}
- (void)drawRect:(NSRect)dirtyRect {
	CGFloat w = self.frame.size.width/data.children.count;
	CGRect pen = CGRectMake(0, 0, w, kTVHeight);
	for (Node *n in data.children) {
		[self drawNode:n inRect:pen];
		pen.origin.x += w;
	}
}

-(Node*)selected; { return selected; }
-(void)setSelected:(Node*)sel;
{
	selected = sel;
	if(selected == data) 
		selected = nil;
	[self setNeedsDisplay:YES];
}

-(IBAction)moveLeft:(id)sender;
{
	if(data.children.count==0) { [self addChild:self]; return; }
	if(!selected) { self.selected = [data.children lastObject]; return; }
	int newIndex = [self.selected.parent.children indexOfObject:self.selected] - 1;
	if(newIndex >= 0)
		self.selected = [self.selected.parent.children objectAtIndex:newIndex];
	else [self addSiblingLeft:self];
}
-(IBAction)moveRight:(id)sender;
{
	if(data.children.count==0) { [self addChild:self]; return; }
	if(!selected) { self.selected = [data.children objectAtIndex:0]; return; }
	int newIndex = [self.selected.parent.children indexOfObject:self.selected] + 1;
	if(newIndex < self.selected.parent.children.count)
		self.selected = [self.selected.parent.children objectAtIndex:newIndex];
	else [self addSiblingRight:self];
}
-(IBAction)moveUp:(id)sender;
{
	if(data.children.count==0) { [self addChild:self]; return; }
	if(!selected) { self.selected = [data.children objectAtIndex:0]; return; }
	if(!self.selected.children.count) { 
		[self addChild:self];
		return;
	}
	self.selected = [self.selected.children objectAtIndex:0];
}
-(IBAction)moveDown:(id)sender;
{
	if(data.children.count==0) { [self addChild:self]; return; }
	if(!selected) {
		Node *n = [data.children objectAtIndex:0];
		while(n.children.count > 0)
			n = [n.children objectAtIndex:0];
		self.selected = n;
		return;
	}
	self.selected = self.selected.parent;
}

-(IBAction)completeSelected:(id)sender;
{
	NSArray *siblings = self.selected.parent.children;
	int selIdx = [siblings indexOfObject:self.selected];
	Node *newSel = self.selected.parent;
	if(siblings.count > 1)
		if(selIdx > 0)
			newSel = [siblings objectAtIndex:selIdx-1];
		else
			newSel = [siblings objectAtIndex:1];
	
	[[self.selected.parent mutableArrayValueForKey:@"children"] removeObject:self.selected];
	self.selected = newSel;
}
-(IBAction)addSiblingLeft:(id)sender;
{
	Node *sibling = [Node nodeWithName:@"Unnamed" children:[NSArray array]];
	[[self.selected.parent mutableArrayValueForKey:@"children"] insertObject:sibling atIndex:0];
	self.selected = sibling;
	[self renameSelected:nil];
}
-(IBAction)addSiblingRight:(id)sender;
{
	Node *sibling = [Node nodeWithName:@"Unnamed" children:[NSArray array]];
	[[self.selected.parent mutableArrayValueForKey:@"children"] addObject:sibling];
	self.selected = sibling;
	[self renameSelected:nil];
}

-(IBAction)addChild:(id)sender;
{
	Node *child = [Node nodeWithName:@"Unnamed" children:[NSArray array]];
	[[self.selected?:data mutableArrayValueForKey:@"children"] addObject:child];
	self.selected = child;
	[self renameSelected:nil];
}
-(IBAction)renameSelected:(id)sender;
{
	if(!selected) return;
	
	editor.frame = selected.frame;
	[editor setHidden:NO];
	editor.stringValue = selected.name;
	[self.window setIgnoresMouseEvents:NO];
	[NSApp activateIgnoringOtherApps:YES];
	[self.window makeKeyAndOrderFront:nil];
	[self.window makeFirstResponder:editor];
}
-(IBAction)doneRenamingSelected:(id)sender;
{
	[self.window makeFirstResponder:nil];
	[editor setHidden:YES];
	selected.name = editor.stringValue;
	[self setNeedsDisplay:YES];
	[self.window setIgnoresMouseEvents:YES];
	[NSApp deactivate];
}

@end
