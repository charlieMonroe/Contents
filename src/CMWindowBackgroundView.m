//
//  XUWindowBackgroundView.m
//  UctoX
//
//  Created by Krystof Vasa on 7/8/09.
//  Copyright 2009 Fuel Collective, LLC. All rights reserved.
//

#import "CMWindowBackgroundView.h"


@implementation CMWindowBackgroundView

- (void)drawRect:(NSRect)dirtyRect {
	[[NSColor colorWithPatternImage:[NSImage imageNamed:@"VerticalStripes"]] set];
	[[NSBezierPath bezierPathWithRect:[self bounds]] fill];
}

-(void)removeFromSuperview{
	[super removeFromSuperview];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"NSViewWasRemovedFromSuperview" object:self];
}

@end
