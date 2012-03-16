//
//  CMInstallerViewLoader.m
//  LibraryLiberty
//
//  Created by Krystof Vasa on 9/4/09.
//  Copyright 2009 FuelCollective, LLC. All rights reserved.
//

#import "CMInstallerViewLoader.h"
#import "CMFile.h"

@interface _CMPathAssociatedMenuItem : NSMenuItem{
	NSString *_path;
}

-(NSMenuItem*)setPath:(NSString*)path;
-(NSString*)path;
@end
@implementation _CMPathAssociatedMenuItem

-(NSMenuItem*)setPath:(NSString*)path{
	[_path release];
	_path = [path retain];
	return self;
}
-(NSString*)path{
	return _path;
}
- (void) dealloc{
	[_path release];
	[super dealloc];
}


@end


static CMInstallerViewLoader *_installer;

@implementation CMInstallerViewLoader

+(NSSize)minContentSize{
	return NSMakeSize(572, 341);
}

-(IBAction)cancel:(id)sender{
	[(CMInstallerCanvas*)[self view] setMode:0];
}
-(IBAction)install:(id)sender{
	NSString *target = [[[NSString stringWithFormat:@"%@/Library", [_homeComputerButton indexOfSelectedItem]==0?@"~":@""] stringByExpandingTildeInPath] stringByAppendingPathComponent:[(_CMPathAssociatedMenuItem*)[_optionsPopupButton selectedItem] path]];
	
	if ([[(_CMPathAssociatedMenuItem*)[_optionsPopupButton selectedItem] path] isEqualToString:@"Applications"]){
		[NSString stringWithFormat:@"%@/Applications", [_homeComputerButton indexOfSelectedItem]==0?@"~":@""];
	}
	
	[[NSFileManager defaultManager] createDirectoryAtPath:target withIntermediateDirectories:YES attributes:nil error:nil];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:[target stringByAppendingPathComponent:[_path lastPathComponent]]]){
		if ([[NSAlert alertWithMessageText:[NSString stringWithFormat:@"An item named \"%@\" already exist at the target location. Do you want to replace it?", [_path lastPathComponent]] defaultButton:@"Cancel" alternateButton:@"Replace" otherButton:@"" informativeTextWithFormat:@"This action can't be undone."] runModal]==NSAlertDefaultReturn){
			return;
		}
	}
	if (![CMFile copyFileReplacingOldOne:_path toFolder:target]){
		[[NSAlert alertWithMessageText:[NSString stringWithFormat:@"An error occurred while installing \"%@\".", [_path lastPathComponent]] defaultButton:@"OK" alternateButton:@"" otherButton:@"" informativeTextWithFormat:@"."] runModal];
	}else{
		[(CMInstallerCanvas*)[self view] setMode:0];
	}
}

+(id)loader{
	if (_installer==nil){
		_installer = [[self alloc] initWithNibName:@"Installer"];
	}
	return _installer;
}

-(void)loadItem:(NSString*)path{
	[_path release];
	_path = [path retain];
	
	[_optionsPopupButton removeAllItems];
	
	NSString *ext = [[path pathExtension] lowercaseString];
	if ([ext isEqualToString:@"qlgenerator"]){
		//QL generator
		_CMPathAssociatedMenuItem *item = [[[_CMPathAssociatedMenuItem alloc] initWithTitle:@"QuickLook" action:nil keyEquivalent:@""] autorelease];
		[item setPath:@"QuickLook"];
		
		[[_optionsPopupButton menu] addItem:item];
	}else if ([[NSArray arrayWithObjects:@"jpg", @"jpeg", @"tif", @"tiff", @"png", @"icns", @"gif", @"bmp", @"jp2", @"pdf", @"psd", @"pict", @"sgi", @"tga", nil] containsObject:ext]){
		//Picture
		_CMPathAssociatedMenuItem *item = [[[_CMPathAssociatedMenuItem alloc] initWithTitle:@"Desktop Pictures" action:nil keyEquivalent:@""] autorelease];
		[item setPath:@"Desktop Pictures"];
		
		[[_optionsPopupButton menu] addItem:item];
	}else if ([ext isEqualToString:@"bundle"]){
		//Generic bundle
		_CMPathAssociatedMenuItem *item = [[[_CMPathAssociatedMenuItem alloc] initWithTitle:@"Address Book Plug-ins" action:nil keyEquivalent:@""] autorelease];
		[item setPath:@"Address Book Plug-Ins"];
		[[_optionsPopupButton menu] addItem:item];
		
		item = [[[_CMPathAssociatedMenuItem alloc] initWithTitle:@"iMovie Plug-ins" action:nil keyEquivalent:@""] autorelease];
		[item setPath:@"iMovie/Plug-ins"];
		[[_optionsPopupButton menu] addItem:item];
		
		item = [[[_CMPathAssociatedMenuItem alloc] initWithTitle:@"Input Managers" action:nil keyEquivalent:@""] autorelease];
		[item setPath:@"InputManagers"];
		[[_optionsPopupButton menu] addItem:item];
		
		item = [[[_CMPathAssociatedMenuItem alloc] initWithTitle:@"Internet Plug-Ins" action:nil keyEquivalent:@""] autorelease];
		[item setPath:@"Internet Plug-Ins"];
		[[_optionsPopupButton menu] addItem:item];
		
		item = [[[_CMPathAssociatedMenuItem alloc] initWithTitle:@"iTunes Plug-ins" action:nil keyEquivalent:@""] autorelease];
		[item setPath:@"iTunes/iTunes Plug-ins"];
		[[_optionsPopupButton menu] addItem:item];
	}else if ([ext isEqualToString:@"scpt"]){
		_CMPathAssociatedMenuItem *item = [[[_CMPathAssociatedMenuItem alloc] initWithTitle:@"Address Book Plug-ins" action:nil keyEquivalent:@""] autorelease];
		[item setPath:@"Address Book Plug-Ins"];
		[[_optionsPopupButton menu] addItem:item];
	}else if ([ext isEqualToString:@"action"]){
		_CMPathAssociatedMenuItem *item = [[[_CMPathAssociatedMenuItem alloc] initWithTitle:@"Automator" action:nil keyEquivalent:@""] autorelease];
		[item setPath:@"Automator"];
		[[_optionsPopupButton menu] addItem:item];
	}else if ([ext isEqualToString:@"colorpicker"]){
		_CMPathAssociatedMenuItem *item = [[[_CMPathAssociatedMenuItem alloc] initWithTitle:@"ColorPickers" action:nil keyEquivalent:@""] autorelease];
		[item setPath:@"ColorPickers"];
		[[_optionsPopupButton menu] addItem:item];
	}else if ([ext isEqualToString:@"icc"]){
		_CMPathAssociatedMenuItem *item = [[[_CMPathAssociatedMenuItem alloc] initWithTitle:@"ColorSync Profiles" action:nil keyEquivalent:@""] autorelease];
		[item setPath:@"ColorSync/Profiles"];
		[[_optionsPopupButton menu] addItem:item];
	}else if ([ext isEqualToString:@"qtz"]){
		_CMPathAssociatedMenuItem *item = [[[_CMPathAssociatedMenuItem alloc] initWithTitle:@"Quartz Compositions" action:nil keyEquivalent:@""] autorelease];
		[item setPath:@"Compositions"];
		[[_optionsPopupButton menu] addItem:item];
	}else if ([ext isEqualToString:@"plugin"]){
		_CMPathAssociatedMenuItem *item = [[[_CMPathAssociatedMenuItem alloc] initWithTitle:@"Contextual Menu Items" action:nil keyEquivalent:@""] autorelease];
		[item setPath:@"Contextual Menu Items"];
		[[_optionsPopupButton menu] addItem:item];
		
		item = [[[_CMPathAssociatedMenuItem alloc] initWithTitle:@"Internet Plug-Ins" action:nil keyEquivalent:@""] autorelease];
		[item setPath:@"Internet Plug-Ins"];
		[[_optionsPopupButton menu] addItem:item];
	}else if ([ext isEqualToString:@"dictionary"]){
		_CMPathAssociatedMenuItem *item = [[[_CMPathAssociatedMenuItem alloc] initWithTitle:@"Dictionaries" action:nil keyEquivalent:@""] autorelease];
		[item setPath:@"Dictionaries"];
		[[_optionsPopupButton menu] addItem:item];
	}else if ([ext isEqualToString:@"qfilter"]){
		_CMPathAssociatedMenuItem *item = [[[_CMPathAssociatedMenuItem alloc] initWithTitle:@"Quartz Filters" action:nil keyEquivalent:@""] autorelease];
		[item setPath:@"Filters"];
		[[_optionsPopupButton menu] addItem:item];
	}else if ([ext isEqualToString:@"ttf"]){
		_CMPathAssociatedMenuItem *item = [[[_CMPathAssociatedMenuItem alloc] initWithTitle:@"Fonts" action:nil keyEquivalent:@""] autorelease];
		[item setPath:@"Fonts"];
		[[_optionsPopupButton menu] addItem:item];
	}else if ([ext isEqualToString:@"otf"]){
		_CMPathAssociatedMenuItem *item = [[[_CMPathAssociatedMenuItem alloc] initWithTitle:@"Fonts" action:nil keyEquivalent:@""] autorelease];
		[item setPath:@"Fonts"];
		[[_optionsPopupButton menu] addItem:item];
	}else if ([ext isEqualToString:@"framework"]){
		_CMPathAssociatedMenuItem *item = [[[_CMPathAssociatedMenuItem alloc] initWithTitle:@"Frameworks" action:nil keyEquivalent:@""] autorelease];
		[item setPath:@"Frameworks"];
		[[_optionsPopupButton menu] addItem:item];
	}else if ([ext isEqualToString:@"keychain"]){
		_CMPathAssociatedMenuItem *item = [[[_CMPathAssociatedMenuItem alloc] initWithTitle:@"Keychains" action:nil keyEquivalent:@""] autorelease];
		[item setPath:@"Keychains"];
		[[_optionsPopupButton menu] addItem:item];
	}else if ([ext isEqualToString:@"plist"]){
		_CMPathAssociatedMenuItem *item = [[[_CMPathAssociatedMenuItem alloc] initWithTitle:@"Launch Agents" action:nil keyEquivalent:@""] autorelease];
		[item setPath:@"LaunchAgents"];
		[[_optionsPopupButton menu] addItem:item];
		
		item = [[[_CMPathAssociatedMenuItem alloc] initWithTitle:@"Launch Daemons" action:nil keyEquivalent:@""] autorelease];
		[item setPath:@"LaunchDaemons"];
		[[_optionsPopupButton menu] addItem:item];
		
		item = [[[_CMPathAssociatedMenuItem alloc] initWithTitle:@"Preferences" action:nil keyEquivalent:@""] autorelease];
		[item setPath:@"Preferences"];
		[[_optionsPopupButton menu] addItem:item];
	}else if ([ext isEqualToString:@"prefpane"]){
		_CMPathAssociatedMenuItem *item = [[[_CMPathAssociatedMenuItem alloc] initWithTitle:@"Preference Panes" action:nil keyEquivalent:@""] autorelease];
		[item setPath:@"PreferencePanes"];
		[[_optionsPopupButton menu] addItem:item];
	}else if ([ext isEqualToString:@"component"]){
		_CMPathAssociatedMenuItem *item = [[[_CMPathAssociatedMenuItem alloc] initWithTitle:@"QuickTime Plugins" action:nil keyEquivalent:@""] autorelease];
		[item setPath:@"QuickTime"];
		[[_optionsPopupButton menu] addItem:item];
	}else if ([ext isEqualToString:@"savedsearch"]){
		_CMPathAssociatedMenuItem *item = [[[_CMPathAssociatedMenuItem alloc] initWithTitle:@"Saved Searches" action:nil keyEquivalent:@""] autorelease];
		[item setPath:@"Saved Searches"];
		[[_optionsPopupButton menu] addItem:item];
	}else if ([ext isEqualToString:@"saver"]){
		_CMPathAssociatedMenuItem *item = [[[_CMPathAssociatedMenuItem alloc] initWithTitle:@"Screen Savers" action:nil keyEquivalent:@""] autorelease];
		[item setPath:@"Screen Savers"];
		[[_optionsPopupButton menu] addItem:item];
	}else if ([ext isEqualToString:@"aiff"]){
		_CMPathAssociatedMenuItem *item = [[[_CMPathAssociatedMenuItem alloc] initWithTitle:@"Sounds" action:nil keyEquivalent:@""] autorelease];
		[item setPath:@"Sounds"];
		[[_optionsPopupButton menu] addItem:item];
	}else if ([ext isEqualToString:@"mdimporter"]){
		_CMPathAssociatedMenuItem *item = [[[_CMPathAssociatedMenuItem alloc] initWithTitle:@"Spotlight Plugins" action:nil keyEquivalent:@""] autorelease];
		[item setPath:@"Spotlight"];
		[[_optionsPopupButton menu] addItem:item];
	}else if ([ext isEqualToString:@"wdgt"]){
		_CMPathAssociatedMenuItem *item = [[[_CMPathAssociatedMenuItem alloc] initWithTitle:@"Widgets" action:nil keyEquivalent:@""] autorelease];
		[item setPath:@"Widgets"];
		[[_optionsPopupButton menu] addItem:item];
	}else if ([ext isEqualToString:@"wdgt"]){
		_CMPathAssociatedMenuItem *item = [[[_CMPathAssociatedMenuItem alloc] initWithTitle:@"Scripting Additions" action:nil keyEquivalent:@""] autorelease];
		[item setPath:@"ScriptingAdditions"];
		[[_optionsPopupButton menu] addItem:item];
	}else if ([ext isEqualToString:@"app"]){
		_CMPathAssociatedMenuItem *item = [[[_CMPathAssociatedMenuItem alloc] initWithTitle:@"Applications" action:nil keyEquivalent:@""] autorelease];
		[item setPath:@"Applications"];
		[[_optionsPopupButton menu] addItem:item];
	}else{
		_CMPathAssociatedMenuItem *item = [[[_CMPathAssociatedMenuItem alloc] initWithTitle:@"Application Support" action:nil keyEquivalent:@""] autorelease];
		[item setPath:@"Application Support"];
		[[_optionsPopupButton menu] addItem:item];
		
		item = [[[_CMPathAssociatedMenuItem alloc] initWithTitle:@"Input Managers" action:nil keyEquivalent:@""] autorelease];
		[item setPath:@"InputManagers"];
		[[_optionsPopupButton menu] addItem:item];
		
		item = [[[_CMPathAssociatedMenuItem alloc] initWithTitle:@"Library" action:nil keyEquivalent:@""] autorelease];
		[item setPath:@""];
		[[_optionsPopupButton menu] addItem:item];
		
		item = [[[_CMPathAssociatedMenuItem alloc] initWithTitle:@"Preferences" action:nil keyEquivalent:@""] autorelease];
		[item setPath:@"Preferences"];
		[[_optionsPopupButton menu] addItem:item];
	}
	
}

@end
