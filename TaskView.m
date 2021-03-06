//  Created by Joachim Bengtsson on 2010-07-16.

static float frand() {
	return (rand()%10000)/10000.f;
}

#import "TaskView.h"
#import <Carbon/Carbon.h>

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
-(NSString*)description;
{
	return self.name;
}
@end




@implementation TaskView
@synthesize treeChanged;

- (id)initWithFrame:(NSRect)frame {
    if(![super initWithFrame:frame]) return nil;
	
	data = [[Node nodeWithName:nil children:nil] retain];
	
	selected = nil;
	focusStack = [NSMutableArray new];
	
	colNormal = [[NSColor colorWithCalibratedRed:0.475 green:0.863 blue:0.492 alpha:0.7] retain];
	colSelected = [[NSColor colorWithCalibratedRed:0.275 green:0.663 blue:0.292 alpha:0.7] retain];
	colFocused = [[NSColor colorWithCalibratedRed:0.275 green:0.463 blue:0.663 alpha:0.7] retain];
		
    return self;
}
-(void)dealloc;
{
  [data release];
  [colNormal release]; [colSelected release]; [colFocused release];
  [focusStack release];
  [super dealloc];
}

-(NSData*)treeData;
{
  return [NSKeyedArchiver archivedDataWithRootObject:data];
}
-(void)setupTreeWithData:(NSData*)data_;
{
  [data release];
  if(data_)
	  data = [[NSKeyedUnarchiver unarchiveObjectWithData:data_] retain];
  else
  	data = [[Node nodeWithName:nil children:nil] retain];
    
  [self setNeedsDisplay:YES];
}


static const CGFloat kTVHeight = 200;
-(NSColor*)colorForNode:(Node*)node;
{
	if(node == selected && [focusStack containsObject:node])
		return [colSelected blendedColorWithFraction:0.5 ofColor:colFocused];
	else if(node == selected)
		return colSelected;
	else if([focusStack containsObject:node])
		return colFocused;
	return colNormal;
}

- (void)drawNode:(Node*)node inRect:(CGRect)f;
{
	NSColor *fill = [self colorForNode:node];
	NSColor *border = [[fill blendedColorWithFraction:0.2 ofColor:[NSColor blackColor]] retain];
	NSColor *textColor = [[fill blendedColorWithFraction:0.8 ofColor:[NSColor blackColor]] retain];

	if(node == selected) {
		Node *p = node;
		do {
			CGRect laneR = p.frame;
			laneR.size.height = self.frame.size.height - laneR.origin.y;
			[[[self colorForNode:p] colorWithAlphaComponent:0.3] set];

			[[NSBezierPath bezierPathWithRect:laneR] fill];
			
			p = p.parent;
			if(p == data || (focusStack.count > 0 && p == [(Node*)focusStack.lastObject parent])) break;
		} while(YES);
	}
	
	CGRect r = CGRectInset(f, 10, 10);
	NSBezierPath *bzp = [NSBezierPath bezierPathWithRoundedRect:r xRadius:0 yRadius:0];
	[fill set];
	[bzp fill];

	[border set];
	[bzp stroke];

	NSMutableParagraphStyle *centered = [[[NSMutableParagraphStyle alloc] init] autorelease];
	centered.alignment = NSCenterTextAlignment;
  
  NSDictionary *stringAttrs = $dict(
		NSParagraphStyleAttributeName, centered,
		NSForegroundColorAttributeName, textColor,
		NSFontAttributeName, [NSFont systemFontOfSize:20],
	);
	
	CGRect textR = r;
  CGSize txSz = [[node name] sizeWithAttributes:stringAttrs];
	textR.size.height -= textR.size.height/2. - (txSz.height*MIN(1., txSz.width/r.size.width))/2.;
	
	[[node name] drawInRect:textR withAttributes:stringAttrs];
	
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
	if(focusStack.count == 0)
		for (Node *n in data.children) {
			[self drawNode:n inRect:pen];
			pen.origin.x += w;
		}
	else {
		pen.size.width = self.frame.size.width;
		[self drawNode:focusStack.lastObject inRect:pen];
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
-(Node*)bottommost;
{
  if(focusStack.count > 0)
    return focusStack.lastObject;
  return [data.children objectAtIndex:0];
}


-(IBAction)moveLeft:(id)sender;
{
	if(data.children.count==0) { [self addChild:self]; return; }
	if(!selected) { self.selected = self.bottommost; return; }
	if(selected == focusStack.lastObject) { self.selected = nil; return; }
	
	int newIndex = [self.selected.parent.children indexOfObject:self.selected] - 1;
	if(newIndex >= 0)
		self.selected = [self.selected.parent.children objectAtIndex:newIndex];
	else [self addSiblingLeft:self];
}
-(IBAction)moveRight:(id)sender;
{
	if(data.children.count==0) { [self addChild:self]; return; }
	if(!selected) { self.selected = self.bottommost; return; }
	if(selected == focusStack.lastObject) { self.selected = nil; return; }
	
	int newIndex = [self.selected.parent.children indexOfObject:self.selected] + 1;
	if(newIndex < self.selected.parent.children.count)
		self.selected = [self.selected.parent.children objectAtIndex:newIndex];
	else [self addSiblingRight:self];
}
-(IBAction)moveUp:(id)sender;
{
	if(data.children.count==0) { [self addChild:self]; return; }
	if(!selected) { self.selected = self.bottommost; return; }
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
		Node *n = self.bottommost;
		while(n.children.count > 0)
			n = [n.children objectAtIndex:0];
		self.selected = n;
	} else {
		if(self.selected == focusStack.lastObject)
			self.selected = nil;
		else
			self.selected = self.selected.parent;
	}
}

-(IBAction)completeSelected:(id)sender;
{
  if(!selected) return;
  if(selected == focusStack.lastObject) [self unfocus:nil];
  
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
  
  // the lane drawing is a hack. Redraw twice to get the previous frames right.
  [NSTimer tc_scheduledTimerWithTimeInterval:0.01 repeats:NO block:^(NSTimer*t) { [self setNeedsDisplay:YES]; }];
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
	[self.window makeFirstResponder:self];
	selected.name = editor.stringValue;
	[self setNeedsDisplay:YES];
	[self.window setIgnoresMouseEvents:YES];
	[NSApp deactivate];
	[editor removeFromSuperview];
	[editor release]; editor = nil;
  if(treeChanged) treeChanged(self);
}

-(IBAction)focusSelected:(id)sender;
{
  if(!selected) return;
  if(selected == focusStack.lastObject) { return; }
  [focusStack addObject:selected];
  [self setNeedsDisplay:YES];
  // the lane drawing is a hack. Redraw twice to get the previous frames right.
  [NSTimer tc_scheduledTimerWithTimeInterval:0.01 repeats:NO block:^(NSTimer*t) { [self setNeedsDisplay:YES]; }];
}
-(IBAction)unfocus:(id)sender;
{
  if(focusStack.count == 0) return;
  [focusStack removeLastObject];
  [self setNeedsDisplay:YES];
  // the lane drawing is a hack. Redraw twice to get the previous frames right.
  [NSTimer tc_scheduledTimerWithTimeInterval:0.01 repeats:NO block:^(NSTimer*t) { [self setNeedsDisplay:YES]; }];
}


-(IBAction)yank:(id)sender;
{
  if(!selected) return;
  if(selected == focusStack.lastObject) [self unfocus:nil];

  
  Node *nodeToYank = [[selected retain] autorelease];
  Node *yankParent = nodeToYank.parent;
  
  NSArray *yankChildren = [nodeToYank children];
  NSMutableArray *siblings = [yankParent mutableArrayValueForKey:@"children"];
  
  NSInteger indexOfSelectedWas = [siblings indexOfObject:selected];
  NSInteger j = indexOfSelectedWas;
  
  if(yankChildren.count > 0)
	self.selected = [yankChildren objectAtIndex:0];
  else if(siblings.count > 1)
		if(indexOfSelectedWas > 0)
			self.selected = [siblings objectAtIndex:indexOfSelectedWas-1];
		else
			self.selected = [siblings objectAtIndex:1];
  else
	self.selected = self.selected.parent;
  
  [siblings removeObject:nodeToYank];
  for (Node *n in yankChildren)
	  [siblings insertObject:n atIndex:j++];
	  
  
  if(treeChanged) treeChanged(self);
  
  [NSTimer tc_scheduledTimerWithTimeInterval:0.01 repeats:NO block:^(NSTimer*t) { [self setNeedsDisplay:YES]; }];
}

-(BOOL)isRenaming;
{
	return editor != nil;
}


- (BOOL)acceptsFirstResponder;
{
	return YES;
}
- (BOOL)performKeyEquivalent:(NSEvent *)evt;
{
  if(evt.keyCode == kVK_Return) [self renameSelected:nil];
  else if(evt.keyCode == kVK_Delete || evt.keyCode == kVK_Space) [self completeSelected:nil];
  else if(evt.keyCode == kVK_ANSI_F) [self focusSelected:nil];
  else if(evt.keyCode == kVK_ANSI_D) [self unfocus:nil];
  else if(evt.keyCode == kVK_ANSI_Y) [self yank:nil];
  else return [super performKeyEquivalent:evt];
  return YES;
}

@end
