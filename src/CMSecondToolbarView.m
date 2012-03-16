//
//  CMSecondToolbarView.m
//  LibraryLiberty
//
//  Created by alto on 8/23/09.
//  Copyright 2009 FuelCollective. All rights reserved.
//

#import "CMSecondToolbarView.h"


@implementation CMSecondToolbarView

- (void)drawRect:(NSRect)dirtyRect {
	NSGradient *grad = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.85] endingColor:[NSColor colorWithCalibratedWhite:0.2 alpha:0.85]] autorelease];
	[grad drawInRect:[self bounds] angle:90.0];
}

@end
