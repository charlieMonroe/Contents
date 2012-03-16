//
//  CMFileCell.m
//  LibraryLiberty
//
//  Created by Krystof Vasa on 9/3/09.
//  Copyright 2009 FuelCollective, LLC. All rights reserved.
//

#import "CMFileCell.h"


@implementation CMFileCell

-(NSRect)expansionFrameWithFrame:(NSRect)cellFrame inView:(NSView *)view{
	float width = 43.0;
	
	NSString *name = [self stringValue];
	
	NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
	[shadow setShadowBlurRadius:0.5];
	[shadow setShadowOffset:NSMakeSize(1.5, -1.5)];
	[shadow setShadowColor:[NSColor colorWithCalibratedWhite:[self isHighlighted]?0.0:1.0 alpha:1.0]];
	
	NSSize nameSize = [name sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont boldSystemFontOfSize:13.0], NSFontAttributeName, shadow, NSShadowAttributeName, nil]];
	
	width += MAX(nameSize.width, 0.0);
	width += 5.0;
	
	NSRect result = NSMakeRect(cellFrame.origin.x, cellFrame.origin.y, width, cellFrame.size.height);	
	return result;
}

- (void)drawWithExpansionFrame:(NSRect)cellFrame inView:(NSView *) view{
	[self drawWithFrame:cellFrame inView:view];
}

-(void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView{
	NSString *path = [self stringValue];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]){
		NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(cellFrame.origin.x + 5.0, cellFrame.origin.y + 4.0, 24.0, 24.0) xRadius:6.0 yRadius:6.0];
		[path setLineWidth:2.0];
		CGFloat *pattern = malloc(2*sizeof(CGFloat));
		pattern[0] = 10.0;
		pattern[1] = 4.0;
		
		[path setLineDash:pattern count:2 phase:0.0];
		[[NSColor colorWithCalibratedWhite:0.75 alpha:1.0] set];
		[path stroke];
		
		free(pattern);
	}else{
		NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:path];
		[icon setFlipped:[controlView isFlipped]];
		[icon drawInRect:NSMakeRect(cellFrame.origin.x + 5.0, cellFrame.origin.y + 4.0, 24.0, 24.0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	}
	
	NSColor *nameTextColor = [self isHighlighted]?[NSColor whiteColor]:[NSColor blackColor];
	NSColor *pathTextColor = [self isHighlighted]?[NSColor colorWithCalibratedWhite:0.65 alpha:1.0]:[NSColor colorWithCalibratedWhite:0.35 alpha:1.0];
	NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
	[shadow setShadowBlurRadius:0.5];
	[shadow setShadowOffset:NSMakeSize(1.5, -1.5)];
	[shadow setShadowColor:[NSColor colorWithCalibratedWhite:[self isHighlighted]?0.0:1.0 alpha:1.0]];
	
	[[path lastPathComponent] drawAtPoint:NSMakePoint(cellFrame.origin.x + 35.0, cellFrame.origin.y + 1.0) withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont boldSystemFontOfSize:13.0], NSFontAttributeName, nameTextColor, NSForegroundColorAttributeName, shadow, NSShadowAttributeName, nil]];

	[path drawAtPoint:NSMakePoint(cellFrame.origin.x + 35.0, cellFrame.origin.y + 18.0) withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:10.0], NSFontAttributeName, pathTextColor, NSForegroundColorAttributeName, nil]];
	
}

@end
