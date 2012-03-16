//
//  CMHUDGlossyButton.m
//  LibraryLiberty
//
//  Created by Krystof Vasa on 9/4/09.
//  Copyright 2009 FuelCollective, LLC. All rights reserved.
//

#import "CMHUDGlossyButton.h"


@implementation CMHUDGlossyButton
-(void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView{
	NSImage *leftCap = [NSImage imageNamed:[NSString stringWithFormat:@"HUDGlossyButtonLC%@", [self isHighlighted]?@"H" : @"N"]];
	NSImage *middle = [NSImage imageNamed:[NSString stringWithFormat:@"HUDGlossyButtonM%@", [self isHighlighted]?@"H" : @"N"]];
	NSImage *rightCap = [NSImage imageNamed:[NSString stringWithFormat:@"HUDGlossyButtonRC%@", [self isHighlighted]?@"H" : @"N"]];
	
	if ([[self title] isEqualToString:@"Back"]){
		leftCap = [NSImage imageNamed:[NSString stringWithFormat:@"HUDGlossyButtonLA%@", [self isHighlighted]?@"H" : @"N"]];
	}
	
	NSDrawThreePartImage(cellFrame, leftCap, middle, rightCap, NO, NSCompositeSourceOver, 1.0, [controlView isFlipped]);
	
	NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
	[shadow setShadowBlurRadius:0.5];
	[shadow setShadowOffset:NSMakeSize(1.5, -1.5)];
	[shadow setShadowColor:[NSColor colorWithCalibratedWhite:0.0 alpha:1.0]];
	
	NSDictionary *atts = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont boldSystemFontOfSize:12.0], NSFontAttributeName, [NSColor whiteColor], NSForegroundColorAttributeName, shadow, NSShadowAttributeName, nil];
	
	NSSize s = [[self title] sizeWithAttributes:atts];
	[[self title] drawAtPoint:NSMakePoint([[self title] isEqualToString:@"Back"]?19.0:(cellFrame.size.width/2.0 - s.width/2.0), cellFrame.size.height/2.0 - s.height/2.0) withAttributes:atts];
}
@end
