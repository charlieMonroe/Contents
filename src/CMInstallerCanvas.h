//
//  CMInstallerCanvas.h
//  LibraryLiberty
//
//  Created by Krystof Vasa on 9/5/09.
//  Copyright 2009 FuelCollective, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CMInstallerCanvas : NSView {
	int mode;
	
	BOOL _dragginInside;
	float _dragPhase;
	
	float _progressDelta;
	float _bgAlpha;
	NSTimer *_progressTimer;
	
	IBOutlet NSView *_view;
}

-(void)setMode:(int)val;

@end
