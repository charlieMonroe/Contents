//
//  CMLibrarySearcherLoader.h
//  LibraryLiberty
//
//  Created by Krystof Vasa on 9/2/09.
//  Copyright 2009 FuelCollective, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "_CMViewLoader.h"

@interface CMLibrarySearcherLoader : _CMViewLoader {
	IBOutlet NSSearchField *_searchField;
	
	IBOutlet NSProgressIndicator *_indicator;
	
	IBOutlet NSPopUpButton *_homeComputerPopup;
	IBOutlet NSArrayController *_arrayContr;
	
	BOOL _shouldStop;
	BOOL _loading;
}

+(NSSize)minContentSize;

+(id)loader;

-(IBAction)search:(id)sender;

-(void)_searchPath:(NSString*)path forString:(NSString*)string;

-(IBAction)reveal:(id)sender;
-(IBAction)move:(id)sender;
-(IBAction)copy:(id)sender;
-(IBAction)trash:(id)sender;

@end
