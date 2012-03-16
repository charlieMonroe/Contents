//
//  XUWindowBackgroundView.m
//  UctoX
//
//  Created by alto on 7/8/09.
//  Copyright 2009 Silverado High School. All rights reserved.
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
