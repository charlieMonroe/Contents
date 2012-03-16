//
//  LibraryLibertyAppDelegate.m
//  LibraryLiberty
//
//  Created by Krystof Vasa on 8/22/09.
//  Copyright 2009 FuelCollective, LLC. All rights reserved.
//

#import "LibraryLibertyAppDelegate.h"
#import "CMLibraryBrowserLoader.h"
#import "CMLibrarySearcherLoader.h"
#import "CMPreferencesCleaner.h"
#import "CMUninstallerViewLoader.h"
#import "CMInstallerViewLoader.h"
#import "CMBackupperViewLoader.h"

@implementation LibraryLibertyAppDelegate

-(void)awakeFromNib{
	[NSApp setDelegate:self];
	
	[window center];
	
	[[NSNotificationCenter defaultCenter] addObserver:NSApp selector:@selector(terminate:) name:NSWindowWillCloseNotification object:window];
	
	NSToolbar *toolbar = [[[NSToolbar alloc] initWithIdentifier:@"MainToolbar"] autorelease];
	[toolbar setDelegate:self];
	[window setToolbar:toolbar];
	[toolbar setSelectedItemIdentifier:@"UninstallerToolbarItem"];
	
	[self performSelector:@selector(selectUninstaller:) withObject:nil];
}

-(void)selectBrowser:(id)sender{
	[[window toolbar] setSelectedItemIdentifier:@"BrowserToolbarItem"];
	[window setContentMinSize:[CMLibraryBrowserLoader minContentSize]];
	[self setMainWindowContentView:[[CMLibraryBrowserLoader loader] view]];
}
-(void)selectSearcher:(id)sender{
	[[window toolbar] setSelectedItemIdentifier:@"SearcherToolbarItem"];
	[window setContentMinSize:[CMLibrarySearcherLoader minContentSize]];
	[self setMainWindowContentView:[[CMLibrarySearcherLoader loader] view]];
}
-(void)selectPrefCleaner:(id)sender{
	[[window toolbar] setSelectedItemIdentifier:@"PrefCleanerToolbarItem"];
	[window setContentMinSize:[CMPreferencesCleaner minContentSize]];
	[self setMainWindowContentView:[[CMPreferencesCleaner loader] view]];
}
-(void)selectUninstaller:(id)sender{
	[[window toolbar] setSelectedItemIdentifier:@"UninstallerToolbarItem"];
	[window setContentMinSize:[CMUninstallerViewLoader minContentSize]];
	[self setMainWindowContentView:[[CMUninstallerViewLoader loader] view]];
}
-(void)selectInstaller:(id)sender{
	[[window toolbar] setSelectedItemIdentifier:@"InstallerToolbarItem"];
	[window setContentMinSize:[CMInstallerViewLoader minContentSize]];
	[self setMainWindowContentView:[[CMInstallerViewLoader loader] view]];
}
-(void)selectBackupper:(id)sender{
	[[window toolbar] setSelectedItemIdentifier:@"BackupperToolbarItem"];
	[window setContentMinSize:[CMBackupperViewLoader minContentSize]];
	[self setMainWindowContentView:[[CMBackupperViewLoader loader] view]];
}

-(void)setMainWindowContentView:(NSView*)view{
	if ([window contentView]!=view){
		NSRect winFrame = [[self window] frame];
		NSSize contSize = [[[self window] contentView] bounds].size;
		
		//Set the window frame
		float xDelta = contSize.width - [view bounds].size.width;
		winFrame.origin.x += xDelta/2;
		winFrame.size.width -= xDelta;
		float yDelta = contSize.height - [view bounds].size.height;
		winFrame.origin.y += yDelta;
		winFrame.size.height -= yDelta;
		
		
		[[self window] setContentView:view];
		
		[[self window] setFrame:winFrame display:YES animate:YES];
		
	}
}

-(IBAction)showHelp:(id)sender{
	if (![_helpWindow isVisible]){
		[_helpWindow center];
		[_helpWindow makeKeyAndOrderFront:nil];
	}
}

-(NSWindow*)window{
	return window;
}


#pragma mark NSToolbar methods
-(NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag{
	NSToolbarItem *item = nil;
	if ([itemIdentifier isEqualToString:@"BrowserToolbarItem"]){
		item = [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier] autorelease];
		[item setImage:[NSImage imageNamed:@"Browse"]];
		[item setTarget:self];
		[item setAction:@selector(selectBrowser:)];
		[item setLabel:@"Browse Library"];
	}else if ([itemIdentifier isEqualToString:@"SearcherToolbarItem"]){
		item = [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier] autorelease];
		[item setImage:[NSImage imageNamed:@"SearchLibrary"]];
		[item setTarget:self];
		[item setAction:@selector(selectSearcher:)];
		[item setLabel:@"Search Library"];
	}else if ([itemIdentifier isEqualToString:@"PrefCleanerToolbarItem"]){
		item = [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier] autorelease];
		[item setImage:[NSImage imageNamed:@"PrefCleaner"]];
		[item setTarget:self];
		[item setAction:@selector(selectPrefCleaner:)];
		[item setLabel:@"Preferences Cleaner"];
	}else if ([itemIdentifier isEqualToString:@"UninstallerToolbarItem"]){
		item = [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier] autorelease];
		[item setImage:[NSImage imageNamed:@"Uninstaller"]];
		[item setTarget:self];
		[item setAction:@selector(selectUninstaller:)];
		[item setLabel:@"Uninstaller"];
	}else if ([itemIdentifier isEqualToString:@"InstallerToolbarItem"]){
		item = [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier] autorelease];
		[item setImage:[NSImage imageNamed:@"Installer"]];
		[item setTarget:self];
		[item setAction:@selector(selectInstaller:)];
		[item setLabel:@"Installer"];
	}else if ([itemIdentifier isEqualToString:@"BackupperToolbarItem"]){
		item = [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier] autorelease];
		[item setImage:[NSImage imageNamed:@"Backupper"]];
		[item setTarget:self];
		[item setAction:@selector(selectBackupper:)];
		[item setLabel:@"Backupper"];
	}
	
	return item;
}

-(NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar{
	return [NSArray arrayWithObjects:@"BrowserToolbarItem", @"SearcherToolbarItem", @"PrefCleanerToolbarItem", @"UninstallerToolbarItem", @"InstallerToolbarItem", @"BackupperToolbarItem", nil];
}

-(NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar{
	return [self toolbarAllowedItemIdentifiers:toolbar];
}

-(NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar{
	return [self toolbarAllowedItemIdentifiers:toolbar];
}



@end
