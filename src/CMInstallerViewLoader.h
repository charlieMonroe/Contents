//
//  CMInstallerViewLoader.h
//  LibraryLiberty
//
//  Created by Krystof Vasa on 9/4/09.
//  Copyright 2009 FuelCollective, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "_CMViewLoader.h"
#import "CMInstallerCanvas.h"

@interface CMInstallerViewLoader : _CMViewLoader {
	NSString *_path;
	
	IBOutlet NSPopUpButton *_homeComputerButton;
	IBOutlet NSPopUpButton *_optionsPopupButton;
}

+(NSSize)minContentSize;

+(id)loader;

-(IBAction)cancel:(id)sender;
-(IBAction)install:(id)sender;

-(void)loadItem:(NSString*)path;

@end
