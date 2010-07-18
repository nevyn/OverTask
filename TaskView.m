//  Created by Joachim Bengtsson on 2010-07-16.

float frand() {
	return (rand()%10000)/10000.f;
}

#import "TaskView.h"

@interface Node : NSObject <NSCoding>
{
	Node *parent;
	NSString *name;
	NSMutableArray *children;
	CGRect frame; // transient
}
@property (copy) NSString *name;
@property (assign) Node *parent;
@property CGRect frame;
@end
@implementation Node
@synthesize name, parent, frame;
-(id)initWithName:(NSString *)name_ children:(NSArray*)children_;
{
	name = [name_ copy];
	children = [NSMutableArray new];
	for (Node *child in children_)
		[[self mutableArrayValueForKey:@"children"] addObject:child];
  
  return self;
}
+(id)nodeWithName:(NSString *)name_ children:(NSArray*)children_;
{
	return [[[self class] alloc] initWithName:name_ children:children_];
}

- (id)initWithCoder:(NSCoder *)decoder;
{
	name = [[decoder decodeObjectForKey:@"name"] retain];

	children = [NSMutableArray new];
  NSArray *newChildren = [decoder decodeObjectForKey:@"children"];
 	for (Node *child in newChildren)
		[[self mutableArrayValueForKey:@"children"] addObject:child];
	
  return self;
}
- (void)encodeWithCoder:(NSCoder *)coder;
{
	[coder encodeObject:name forKey:@"name"];
  [coder encodeObject:children forKey:@"children"];
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
	[super dealloc];
}
@end




@implementation TaskView
@synthesize treeChanged;

- (id)initWithFrame:(NSRect)frame {
    if(![super initWithFrame:frame]) return nil;
	
	data = [[Node nodeWithName:nil children:nil] retain];
	
	selected = nil;
	
	fill = [[NSColor colorWithCalibratedRed:0.475 green:0.863 blue:0.492 alpha:0.9] retain];
	border = [[NSColor colorWithCalibratedRed:0.284 green:0.611 blue:0.306 alpha:0.9] retain];
	textColor = [[NSColor colorWithCalibratedRed:0.106 green:0.257 blue:0.116 alpha:0.9] retain];
	
	selFill = [[NSColor colorWithCalibratedRed:0.275 green:0.663 blue:0.292 alpha:0.9] retain];
	selBorder = [[NSColor colorWithCalibratedRed:0.184 green:0.411 blue:0.206 alpha:0.9] retain];
	selTextColor = [[NSColor colorWithCalibratedRed:0.156 green:0.317 blue:0.166 alpha:0.9] retain];
	
    return self;
}
-(void)dealloc;
{
	[data release];
  [fill release]; [border release]; [textColor release];
  [selFill release]; [selBorder release]; [selTextColor release];
  [super dealloc];
}

-(NSData*)treeData;
{
	return [NSKeyedArchiver archivedDataWithRootObject:data];
}
-(void)setupTreeWithData:(NSData*)data_;
{
	[data release];
  data = [[NSKeyedUnarchiver unarchiveObjectWithData:data_] retain];
  [self setNeedsDisplay:YES];
}


static const CGFloat kTVHeight = 200;

- (void)drawNode:(Node*)node inRect:(CGRect)f;
{
	if(node == selected) {
		Node *p = node;
		do {
			CGRect laneR = p.frame;
			laneR.size.height = self.frame.size.height - laneR.origin.y;
			[[NSColor colorWithCalibratedRed:0.475 green:0.863 blue:0.492 alpha:0.3] set];

			[[NSBezierPath bezierPathWithRect:laneR] fill];
		} while((p = p.parent) != data);
	}
	
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
  if(treeChanged) treeChanged(self);
}
-(IBAction)addSiblingLeft:(id)sender;
{
	Node *sibling = [Node nodeWithName:@"Unnamed" children:[NSArray array]];
	[[self.selected.parent mutableArrayValueForKey:@"children"] insertObject:sibling atIndex:0];
	self.selected = sibling;
	[self performSelector:@selector(renameSelected:) withObject:nil afterDelay:0];
}
-(IBAction)addSiblingRight:(id)sender;
{
	Node *sibling = [Node nodeWithName:@"Unnamed" children:[NSArray array]];
	[[self.selected.parent mutableArrayValueForKey:@"children"] addObject:sibling];
	self.selected = sibling;
	[self performSelector:@selector(renameSelected:) withObject:nil afterDelay:0];
}

-(IBAction)addChild:(id)sender;
{
	Node *child = [Node nodeWithName:@"Unnamed" children:[NSArray array]];
	[[self.selected?:data mutableArrayValueForKey:@"children"] addObject:child];
	self.selected = child;
	[self performSelector:@selector(renameSelected:) withObject:nil afterDelay:0];
}
-(IBAction)renameSelected:(id)sender;
{
	if(!selected || editor) return;
	
	editor = [[NSTextField alloc] initWithFrame:selected.frame];
	[self addSubview:editor];
	editor.font = [NSFont systemFontOfSize:20];
	editor.alignment = NSCenterTextAlignment;
	editor.stringValue = selected.name;
	editor.target = self;
	editor.action = @selector(doneRenamingSelected:);
	
	[self.window setIgnoresMouseEvents:NO];
	[NSApp activateIgnoringOtherApps:YES];
	[self.window makeKeyAndOrderFront:nil];
	[self.window makeFirstResponder:editor];
}
-(IBAction)doneRenamingSelected:(id)sender;
{
	[self.window makeFirstResponder:nil];
	selected.name = editor.stringValue;
	[self setNeedsDisplay:YES];
	[self.window setIgnoresMouseEvents:YES];
	[NSApp deactivate];
	[editor removeFromSuperview];
	[editor release]; editor = nil;
  if(treeChanged) treeChanged(self);
}

-(BOOL)isRenaming;
{
	return editor != nil;
}

@end
