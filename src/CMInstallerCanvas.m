//
//  CMInstallerCanvas.m
//  LibraryLiberty
//
//  Created by Krystof Vasa on 9/5/09.
//  Copyright 2009 FuelCollective, LLC. All rights reserved.
//

#import "CMInstallerCanvas.h"
#import "CMFile.h"
#import "CMInstallerViewLoader.h"

#define CMStripesWidth 15.0

@implementation CMInstallerCanvas

-(void)_nextProgressFrame:(id)sender{
	if (_dragginInside){
		_dragPhase+=2.5;
		[self display];
		return;
	}
	
	if (mode != 1){
		return;
	}
	
	if (_bgAlpha<0.5){
		_bgAlpha+=0.1;
	}
	
	_progressDelta+=1.0;
	_progressDelta = (float)((int)_progressDelta % (int)(CMStripesWidth*2.0));

	[self display];
}
-(void)awakeFromNib{
	mode = 0;
	_progressTimer = [[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(_nextProgressFrame:) userInfo:nil repeats:YES] retain];
	
	[[NSRunLoop mainRunLoop] addTimer:_progressTimer forMode:NSEventTrackingRunLoopMode];
	
	[self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
}
-(NSDragOperation)draggingEntered:(id < NSDraggingInfo >)sender{
	if (mode!=0){
		return NSDragOperationNone;
	}
	_dragginInside = YES;
	[self display];
	return NSDragOperationCopy;
}
-(void)draggingExited:(id < NSDraggingInfo >)sender{
	_dragginInside = NO;
	[self display];
}

- (void)drawRect:(NSRect)dirtyRect {
	if (mode == 0){
		NSRect r = [self bounds];
		
		[[NSColor colorWithPatternImage:[NSImage imageNamed:@"VerticalStripes"]] set];
		[[NSBezierPath bezierPathWithRect:r] fill];
		
		if (_dragginInside){
			[[NSColor colorWithCalibratedWhite:0.0 alpha:0.3] set];
			[[NSBezierPath bezierPathWithRect:r] fill];
		}
		
		NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(r, 5.0, 5.0) xRadius:15.0 yRadius:15.0];
		[path setLineWidth:3.0];
		CGFloat *pattern = malloc(2*sizeof(CGFloat));
		pattern[0] = 10.0;
		pattern[1] = 4.0;
		
		[path setLineDash:pattern count:2 phase:_dragPhase];
		[[NSColor colorWithCalibratedWhite:_dragginInside?0.35:0.55 alpha:1.0] set];
		[path stroke];
		
		free(pattern);
		
		NSString *prompt = @"Drop a file to install here";
		
		[[NSImage imageNamed:@"DocImage"] drawAtPoint:NSMakePoint((r.size.width - 256.0)/2.0, (r.size.height - 256.0)/2.0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
		
		NSDictionary *atts = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont boldSystemFontOfSize:24.0], NSFontAttributeName, [NSColor colorWithCalibratedWhite:0.6 alpha:1.0], NSForegroundColorAttributeName, nil];
		NSSize s = [prompt sizeWithAttributes:atts];
		
		[[NSColor colorWithCalibratedWhite:0.0 alpha:0.8] set];
		[[NSBezierPath bezierPathWithRoundedRect:NSMakeRect((r.size.width - s.width)/2.0 - 5.0, (r.size.height - s.height)/2.0 - 5.0, s.width + 10.0, s.height + 10.0) xRadius:8.0 yRadius:8.0] fill];
		
		[prompt drawAtPoint:NSMakePoint((r.size.width - s.width)/2.0, (r.size.height - s.height)/2.0) withAttributes:atts];
		
	}else if (mode == 1){
		//The background
		NSRect r = [self bounds];
		float x;
		
		[NSBezierPath setDefaultLineWidth:CMStripesWidth];
		
		NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
		[shadow setShadowColor:[NSColor colorWithCalibratedWhite:0.8 alpha:1.0]];
		[shadow setShadowBlurRadius:6.0];
		[shadow setShadowOffset:NSMakeSize(3.0, 0.0)];
		[shadow set];
		
		BOOL b = NO;
		
		for (x = -30.0;x<r.size.width + 30.0;x+=CMStripesWidth){
			if (b){
				[[NSColor colorWithCalibratedRed:0.255 green:0.471 blue:0.808 alpha:1.0] set];
			}else{
				[[NSColor blackColor] set];
			}
			b = !b;
			[NSBezierPath strokeLineFromPoint:NSMakePoint(x - _progressDelta, -10.0) toPoint:NSMakePoint(x-_progressDelta, r.size.height + 10.0)];
		}
		
		if (_bgAlpha!=0.0){
			shadow = [[[NSShadow alloc] init] autorelease];
			[shadow set];
			
			[[NSColor colorWithCalibratedWhite:0.0 alpha:_bgAlpha] set];
			[[NSBezierPath bezierPathWithRect:r] fill];
		}
		
		shadow = [[[NSShadow alloc] init] autorelease];
		[shadow setShadowColor:[NSColor colorWithCalibratedWhite:0.8 alpha:1.0]];
		[shadow setShadowBlurRadius:6.0];
		[shadow setShadowOffset:NSMakeSize(0.0, 0.0)];
		[shadow set];
		
		NSRect viewRect = NSInsetRect([_view frame], -5.0, -5.0);
		[[NSColor colorWithCalibratedWhite:0.0 alpha:0.4] set];
		[[NSBezierPath bezierPathWithRoundedRect:viewRect xRadius:7.0 yRadius:7.0] fill];
		
		[[[[NSShadow alloc] init] autorelease] set];
	}
	
	NSGradient *grad = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.8] endingColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.0]] autorelease];
	[grad drawInRect:NSMakeRect(0.0, [self bounds].size.height - 140.0, [self bounds].size.width, 140.0) angle:270.0];
	
}

-(BOOL)performDragOperation:(id < NSDraggingInfo >)sender{
	_dragginInside = NO;
	[self display];
	NSPasteboard *pBoard = [sender draggingPasteboard];
	NSArray *files = [pBoard propertyListForType:NSFilenamesPboardType];
	if (files == nil || [files count]==0){
		return NO;
	}else{
		[self setMode:1];
		
		[[CMInstallerViewLoader loader] loadItem:[files objectAtIndex:0]];
		
		return YES;
	}
	return NO;
	
}

-(void)setMode:(int)val{
	mode = val;
	
	_bgAlpha = 0.0;
	
	[_view setHidden:mode!=1];
	
	[self setNeedsDisplay:YES];
}

@end
