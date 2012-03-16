//
//  CMActionButton.m
//  LibraryLiberty
//
//  Created by Krystof Vasa on 8/26/09.
//  Copyright 2009 FuelCollective, LLC. All rights reserved.
//

#import "CMActionButton.h"

@implementation CMActionButtonCell

-(void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView{
	cellFrame.origin.x += 3.0;
	cellFrame.size.width -= 3.0;
	
	if ([self isHighlighted]){
		NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
		[shadow setShadowColor:[NSColor whiteColor]];
		[shadow setShadowBlurRadius:3.0];
		[shadow set];
	}
	
	[[self image] setFlipped:[controlView isFlipped]];
	[[self image] drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:[self isHighlighted]?0.6:1.0];
	
	[[self title] drawAtPoint:NSMakePoint(20.0, 0.0) withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor colorWithCalibratedWhite:[self isHighlighted]?0.8:1.0 alpha:1.0], NSForegroundColorAttributeName, [NSFont systemFontOfSize:13.0], NSFontAttributeName, nil]];
	
	[[self image] setFlipped:NO];
}

@end


@implementation CMActionButton


@end
