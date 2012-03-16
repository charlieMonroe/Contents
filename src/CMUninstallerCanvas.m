//
//  CMUninstallerCanvas.m
//  LibraryLiberty
//
//  Created by alto on 9/3/09.
//  Copyright 2009 FuelCollective. All rights reserved.
//

#import "CMUninstallerCanvas.h"
#import "CMFile.h"
#import "CMUninstallerViewLoader.h"

#define CMStripesOffSet [self bounds].size.height/2.0

@implementation CMUninstallerCanvas

-(void)_nextProgressFrame:(id)sender{
	if (_dragginInside){
		_dragPhase+=2.5;
		[self display];
		return;
	}
	
	if (mode != 1){
		return;
	}
	_progressDelta+=2.0;
	if (_progressDelta >= CMStripesOffSet){
		_progressDelta = CMStripesOffSet - _progressDelta;
	}
	[self display];
}
-(void)awakeFromNib{
	mode = 0;
	_progressTimer = [[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(_nextProgressFrame:) userInfo:nil repeats:YES] retain];
	
	[[NSRunLoop mainRunLoop] addTimer:_progressTimer forMode:NSModalPanelRunLoopMode];
	
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
		r.size.height -= 38.0;
		
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
		
		NSString *prompt = @"Drop an application or a bundle here";
		
		[[NSImage imageNamed:@"AppImage"] drawAtPoint:NSMakePoint((r.size.width - 256.0)/2.0, (r.size.height - 256.0)/2.0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
		
		NSDictionary *atts = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont boldSystemFontOfSize:24.0], NSFontAttributeName, [NSColor colorWithCalibratedWhite:0.6 alpha:1.0], NSForegroundColorAttributeName, nil];
		NSSize s = [prompt sizeWithAttributes:atts];
		
		[[NSColor colorWithCalibratedWhite:0.0 alpha:0.8] set];
		[[NSBezierPath bezierPathWithRoundedRect:NSMakeRect((r.size.width - s.width)/2.0 - 5.0, (r.size.height - s.height)/2.0 - 5.0, s.width + 10.0, s.height + 10.0) xRadius:8.0 yRadius:8.0] fill];
		
		[prompt drawAtPoint:NSMakePoint((r.size.width - s.width)/2.0, (r.size.height - s.height)/2.0) withAttributes:atts];
		
	}else if (mode == 1){
		//The loading animation
		NSRect r = [self bounds];
		float x = -r.size.width;
		
		[NSBezierPath setDefaultLineWidth:15.0];
		
		BOOL b = NO;
		
		for (;x<r.size.width * 2.0;x+=15.0){
			if (b){
				[[NSColor colorWithCalibratedRed:1.0 green:0.788 blue:0.29 alpha:1.0] set];
			}else{
				[[NSColor blackColor] set];
			}
			b = !b;
			[NSBezierPath strokeLineFromPoint:NSMakePoint(x - _progressDelta, -10.0) toPoint:NSMakePoint(x-_progressDelta+CMStripesOffSet, r.size.height + 10.0)];
		}
		
		/*****Working sign*****/
		NSString *workingSign = _titleText==nil?@"Looking for matching files...":_titleText;
		NSDictionary *atts = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont boldSystemFontOfSize:24.0], NSFontAttributeName, [NSColor colorWithCalibratedWhite:0.6 alpha:1.0], NSForegroundColorAttributeName, nil];
		NSSize s = [workingSign sizeWithAttributes:atts];
		
		[[NSColor colorWithCalibratedWhite:0.0 alpha:0.8] set];
		[[NSBezierPath bezierPathWithRoundedRect:NSMakeRect((r.size.width - s.width)/2.0 - 10.0, (r.size.height - s.height)/2.0 - 5.0, s.width + 20.0, s.height + 10.0) xRadius:8.0 yRadius:8.0] fill];
		
		[workingSign drawAtPoint:NSMakePoint((r.size.width - s.width)/2.0, (r.size.height - s.height)/2.0) withAttributes:atts];
		
		/******Info text******/
		if (_infoText!=nil){
			atts = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont boldSystemFontOfSize:13.0], NSFontAttributeName, [NSColor colorWithCalibratedWhite:0.65 alpha:1.0], NSForegroundColorAttributeName, nil];
			s = [_infoText sizeWithAttributes:atts];
			
			[[NSColor colorWithCalibratedWhite:0.0 alpha:0.55] set];
			[[NSBezierPath bezierPathWithRoundedRect:NSMakeRect((r.size.width - s.width)/2.0 - 10.0, (r.size.height - s.height)/2.0 - 5.0 - 50.0, s.width + 20.0, s.height + 10.0) xRadius:8.0 yRadius:8.0] fill];
			
			[_infoText drawAtPoint:NSMakePoint((r.size.width - s.width)/2.0, (r.size.height - s.height)/2.0 - 50.0) withAttributes:atts];
		}
	}else{
		[[NSColor colorWithPatternImage:[NSImage imageNamed:@"VerticalStripes"]] set];
		[[NSBezierPath bezierPathWithRect:[self bounds]] fill];
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
		int i;
		for (i=0;i<[files count];++i){
			if ([CMFile isBundleAtPath:[files objectAtIndex:i]]){
				mode = 1;
				[self display];
				
				[[CMUninstallerViewLoader loader] loadItem:[files objectAtIndex:i]];
				
				return YES;
			}
		}
	}
	return NO;
	
}

-(void)setInformativeText:(NSString*)info{
	NSString *tmp = _infoText;
	_infoText = nil;
	[tmp release];
	_infoText = [info retain];
}
-(void)setTitle:(NSString*)title{
	NSString *tmp = _titleText;
	_titleText = nil;
	[tmp release];
	_titleText = [title retain];
}
-(void)setMode:(int)val{
	mode = val;
	
	if (mode >= 2){
		[_toolbarView setHidden:NO];
		[_scrollView setHidden:NO];
	}else{
		[_toolbarView setHidden:YES];
		[_scrollView setHidden:YES];
	}
	
	[self setNeedsDisplay:YES];
}


@end
