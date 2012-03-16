//
//  CMPreferencesCleaner.h
//  LibraryLiberty
//
//  Created by Krystof Vasa on 9/3/09.
//  Copyright 2009 FuelCollective, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "_CMViewLoader.h"

@interface CMPreferencesCleaner : _CMViewLoader {
	IBOutlet NSArrayController *_controller;
	IBOutlet NSPopUpButton *_homeComputerPopup;
	IBOutlet NSProgressIndicator *_indicator;
	
	IBOutlet NSTextField *_statisticField;
	
	BOOL _shouldStop;
	BOOL _loading;
}

+(NSSize)minContentSize;

+(id)loader;

-(IBAction)refresh:(id)sender;

-(IBAction)reveal:(id)sender;
-(IBAction)trash:(id)sender;
-(IBAction)toggleCheck:(id)sender;

-(void)_filterPath:(NSString*)path;

@end
