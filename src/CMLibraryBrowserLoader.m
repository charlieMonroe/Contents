//
//  CMLibraryBrowserLoader.m
//  LibraryLiberty
//
//  Created by Krystof Vasa on 8/23/09.
//  Copyright 2009 FuelCollective, LLC. All rights reserved.
//

#import "CMLibraryBrowserLoader.h"
#import "CMFile.h"

static CMLibraryBrowserLoader *_libBrowserLoader;

@implementation CMLibraryBrowserLoader

+(NSSize)minContentSize{
	return NSMakeSize(698, 424);
}

-(void)_calculateSizes:(NSDate*)calcLock{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	
	[_progressIndicator startAnimation:nil];
	
	NSString *_currPath = [NSString stringWithFormat:@"%@/%@%@", [_libraryTypePopup indexOfSelectedItem]==0?[@"~/" stringByExpandingTildeInPath]:@"", [[[_categories selectedObjects] objectAtIndex:0] objectForKey:@"path"], [_enabledPopup indexOfSelectedItem]==0?@"":@" (disabled)"];
	
	int i;
	for (i = 0; i<[[_items content] count] && calcLock == _sizeCalculationLock ;++i){
		NSMutableDictionary *dict = [[_items content] objectAtIndex:i];
		NSString *item = [_currPath stringByAppendingPathComponent:[dict objectForKey:@"name"]];
		unsigned long long size = [CMFile sizeOfFolder:item];
		
		if (calcLock != _sizeCalculationLock){
			break;
		}
		[dict setObject:[NSNumber numberWithUnsignedLongLong:size] forKey:@"size"];
	}
	
	[_progressIndicator stopAnimation:nil];
		
	[pool release];
}

+(id)loader{
	if (_libBrowserLoader==nil){
		_libBrowserLoader = [[self alloc] initWithNibName:@"LibraryBrowser"];
		
		NSMutableArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"LibraryCategories" ofType:@"icset"]];
		
		[_libBrowserLoader->_categories setContent:array];
		
		/* int o = 0;
				while ([[[array objectAtIndex:o] objectForKey:@"descriptor"] compare:@"QuickLook" options:NSCaseInsensitiveSearch] == NSOrderedAscending){
					++o;
				}
				NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"Here are stored QuickLook plugins.", @"description", @"QuickLook", @"descriptor", [NSImage imageNamed:@"QuickLook"], @"icon", @"Library/QuickLook/", @"path", nil];
				
				[array insertObject:dict atIndex:o];
				
				[NSKeyedArchiver archiveRootObject:array toFile:@"/Users/alto/Desktop/LibraryCategories.icset"];
				
				NSLog(@"%@", [array objectAtIndex:0]);
				//NSQuickLookTemplate */
		
		
		NSArray *items = [_libBrowserLoader->_categories content];
		NSPopUpButton *button = _libBrowserLoader->_categoriesPopup;
		[button removeAllItems];
		
		NSMenu *menu = [[[NSMenu alloc] init] autorelease];
		
		int i;
		for (i=0;i<[items count];++i){
			NSMenuItem *item = [[[NSMenuItem alloc] initWithTitle:[[items objectAtIndex:i] objectForKey:@"descriptor"] action:nil keyEquivalent:@""] autorelease];
			[[[items objectAtIndex:i] objectForKey:@"icon"] setSize:NSMakeSize(16.0, 16.0)];
			[item setImage:[[items objectAtIndex:i] objectForKey:@"icon"]];
			[menu addItem:item];
		}
		
		[button setMenu:menu];
		[button setTarget:_libBrowserLoader];
		[button setAction:@selector(reload:)];
		
		[_libBrowserLoader->_libraryTypePopup setTarget:_libBrowserLoader];
		[_libBrowserLoader->_libraryTypePopup setAction:@selector(reload:)];
		
		[_libBrowserLoader->_enabledPopup setTarget:_libBrowserLoader];
		[_libBrowserLoader->_enabledPopup setAction:@selector(reload:)];
		
		[_libBrowserLoader reload:nil];
	}
	return _libBrowserLoader;
}

-(IBAction)reload:(id)sender{
	@synchronized (self){
		[_sizeCalculationLock autorelease];
		_sizeCalculationLock = [[NSDate date] retain];
	}
	
	[_categories setSelectionIndex:[_categoriesPopup indexOfSelectedItem]];
	
	[_items setContent:nil];
	
	[_enableDisableButton setImage:[NSImage imageNamed:[_enabledPopup indexOfSelectedItem]==0?@"Disabled":@"Enabled"]];
	[_enableDisableButton setTitle:[_enabledPopup indexOfSelectedItem]==0?@"Disable":@"Enable"];
	
	NSString *path = [NSString stringWithFormat:@"%@/%@%@", [_libraryTypePopup indexOfSelectedItem]==0?[@"~/" stringByExpandingTildeInPath]:@"", [[[_categories selectedObjects] objectAtIndex:0] objectForKey:@"path"], [_enabledPopup indexOfSelectedItem]==0?@"":@" (disabled)"];
	NSArray *subs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
	NSWorkspace *wS = [NSWorkspace sharedWorkspace];
	int i;
	
	for (i=0;i<[subs count];++i){
		NSString *item = [path stringByAppendingPathComponent:[subs objectAtIndex:i]];
		NSDictionary *atts = [[NSFileManager defaultManager] attributesOfItemAtPath:item error:NULL];
		[_items addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[subs objectAtIndex:i], @"name", item, @"path", [wS iconForFile:item], @"icon", [atts objectForKey:NSFileModificationDate], @"modDate", [atts objectForKey:NSFileCreationDate], @"creDate", [CMFile isDirectory:item]?nil:[atts objectForKey:NSFileSize], @"size", nil]];
	}
	
	[NSThread detachNewThreadSelector:@selector(_calculateSizes:) toTarget:self withObject:_sizeCalculationLock];
}

-(IBAction)reveal:(id)sender{
	NSArray *sel = [_items selectedObjects];
	if ([sel count]>0){
		[[NSWorkspace sharedWorkspace] selectFile:[[sel objectAtIndex:0] objectForKey:@"path"] inFileViewerRootedAtPath:@""];
	}else{
		NSBeep();
	}
}
-(IBAction)move:(id)sender{
	NSArray *sel = [_items selectedObjects];
	if ([sel count]==0){
		NSBeep();
		return;
	}
	
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseFiles:NO];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setTitle:@"Where would you like to move the selected item?"];
	if ([openPanel runModalForTypes:nil]==NSFileHandlingPanelOKButton){
		if ([CMFile moveFile:[[sel objectAtIndex:0] objectForKey:@"path"] toFolder:[openPanel filename]]){
			[_items removeObject:[sel objectAtIndex:0]];
		}else{
			[[NSAlert alertWithMessageText:@"Could not move selected files to selected destination." defaultButton:@"OK" alternateButton:@"" otherButton:@"" informativeTextWithFormat:@"The destination may not be writeable or you may not have the privilidges to modify the selected file."] runModal];
		}
	}
}
-(IBAction)copy:(id)sender{
	NSArray *sel = [_items selectedObjects];
	if ([sel count]==0){
		NSBeep();
		return;
	}
	
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseFiles:NO];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setTitle:@"Where would you like the selected item to be copied to?"];
	if ([openPanel runModalForTypes:nil]==NSFileHandlingPanelOKButton){
		if ([CMFile copyFile:[[sel objectAtIndex:0] objectForKey:@"path"] toFolder:[openPanel filename]]){
		}else{
			[[NSAlert alertWithMessageText:@"Could not copy selected files to selected destination." defaultButton:@"OK" alternateButton:@"" otherButton:@"" informativeTextWithFormat:@"The destination may not be writeable."] runModal];
		}
	}
}
-(IBAction)trash:(id)sender{
	NSArray *sel = [_items selectedObjects];
	if ([sel count]==0){
		NSBeep();
		return;
	}
	BOOL ask = ![[NSUserDefaults standardUserDefaults] boolForKey:@"CMLBDontDisplayTrashConfirmation"];
	if (ask){
		NSAlert *alert = [NSAlert alertWithMessageText:@"Are you sure you want to move selected item to Trash?" defaultButton:@"Move" alternateButton:@"Cancel" otherButton:@"" informativeTextWithFormat:@"You can’t undo this action."];
		[alert setShowsSuppressionButton:YES];
		if ([alert runModal]==NSAlertAlternateReturn){
			return;
		}
		[[NSUserDefaults standardUserDefaults] setBool:[[alert suppressionButton] state]==NSOnState forKey:@"CMLBDontDisplayTrashConfirmation"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	if ([CMFile moveFile:[[sel objectAtIndex:0] objectForKey:@"path"] toFolder:[@"~/.Trash/" stringByExpandingTildeInPath]]){
		[_items removeObject:[sel objectAtIndex:0]];
	}else{
		[[NSAlert alertWithMessageText:@"Could not remove selected file." defaultButton:@"OK" alternateButton:@"" otherButton:@"" informativeTextWithFormat:@"You may not have the privilidges to modify the selected file."] runModal];
	}
}
-(IBAction)enableDisable:(id)sender{
	NSArray *sel = [_items selectedObjects];
	if ([sel count]==0){
		NSBeep();
		return;
	}
	NSString *path = [NSString stringWithFormat:@"%@/%@%@", [_libraryTypePopup indexOfSelectedItem]==0?[@"~/" stringByExpandingTildeInPath]:@"", [[[_categories selectedObjects] objectAtIndex:0] objectForKey:@"path"], [_enabledPopup indexOfSelectedItem]!=0?@"":@" (disabled)"];
	
	[[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
	
	if ([CMFile moveFile:[[sel objectAtIndex:0] objectForKey:@"path"] toFolder:path]){
		[_items removeObject:[sel objectAtIndex:0]];
	}else{
		[[NSAlert alertWithMessageText:@"Could not enable or disable selected file." defaultButton:@"OK" alternateButton:@"" otherButton:@"" informativeTextWithFormat:@"The destination may not be writeable or you may not have the privilidges to modify the selected file."] runModal];
	}
}

@end
