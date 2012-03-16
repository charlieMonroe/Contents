//
//  CMLibraryBrowserLoader.h
//  LibraryLiberty
//
//  Created by alto on 8/23/09.
//  Copyright 2009 FuelCollective. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "_CMViewLoader.h"

@interface CMLibraryBrowserLoader : _CMViewLoader {
	IBOutlet NSArrayController *_categories;
	IBOutlet NSArrayController *_items;
	
	IBOutlet NSPopUpButton *_enabledPopup;
	IBOutlet NSPopUpButton *_libraryTypePopup;
	IBOutlet NSPopUpButton *_categoriesPopup;
	
	IBOutlet NSButton *_enableDisableButton;
	
	IBOutlet NSProgressIndicator *_progressIndicator;
	
	NSDate *_sizeCalculationLock;
}

+(NSSize)minContentSize;

+(id)loader;

-(IBAction)reload:(id)sender;

-(IBAction)reveal:(id)sender;
-(IBAction)move:(id)sender;
-(IBAction)copy:(id)sender;
-(IBAction)trash:(id)sender;
-(IBAction)enableDisable:(id)sender;

@end
