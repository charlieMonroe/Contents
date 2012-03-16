//
//  CMUninstallerCanvas.h
//  LibraryLiberty
//
//  Created by alto on 9/3/09.
//  Copyright 2009 FuelCollective. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CMUninstallerCanvas : NSView {
	int mode;
	
	BOOL _dragginInside;
	float _dragPhase;
	
	float _progressDelta;
	NSTimer *_progressTimer;
	
	NSString *_titleText;
	NSString *_infoText;
	
	IBOutlet NSView *_toolbarView;
	IBOutlet NSView *_scrollView;
}

-(void)setMode:(int)val;

-(void)setTitle:(NSString*)title;
-(void)setInformativeText:(NSString*)info;

@end
