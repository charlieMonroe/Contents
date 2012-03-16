//
//  CMLibrarySearcherLoader.m
//  LibraryLiberty
//
//  Created by alto on 9/2/09.
//  Copyright 2009 FuelCollective. All rights reserved.
//

#import "CMLibrarySearcherLoader.h"
#import "CMFile.h"

static CMLibrarySearcherLoader *_libSearcherLoader;

@implementation CMLibrarySearcherLoader

+(NSSize)minContentSize{
	return NSMakeSize(581, 318);
}

-(void)_search:(id)sender{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	
	if (_loading){
		_shouldStop = YES;
		while (_shouldStop){
			usleep(500);
		}
		_shouldStop = NO;
	}
	
	if ([[_searchField stringValue] isEqualToString:@""]){
		[_arrayContr setContent:nil];
		return;
	}
	
	_loading = YES;
	_shouldStop = NO;
	[_indicator startAnimation:nil];
	
	[_arrayContr setContent:nil];
	
	NSString *path = [[NSString stringWithFormat:@"%@/Library/", [_homeComputerPopup indexOfSelectedItem]==0?@"~":@""] stringByExpandingTildeInPath];
	NSString *searchString = [[_searchField stringValue] retain];
	[self _searchPath:path forString:searchString];
	[searchString autorelease];
	
	_loading = NO;
	_shouldStop = NO;
	[_indicator stopAnimation:nil];
	
	[pool release];
}
-(void)_searchPath:(NSString*)path forString:(NSString*)string{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	
	if (![path isEqualToString:[CMFile resolvedAlias:path]]){
		return;
	}
	
	NSFileManager *fileMan = [NSFileManager defaultManager];
	NSArray *_items = [fileMan contentsOfDirectoryAtPath:path error:NULL];
	
	int i;
	for (i=0;i<[_items count] && !_shouldStop;++i){
		NSString *p = [path stringByAppendingPathComponent:[_items objectAtIndex:i]];
		
		if ([[_items objectAtIndex:i] rangeOfString:string options:NSCaseInsensitiveSearch].location != NSNotFound && !_shouldStop){
			[_arrayContr addObject:p];
		}
		
		if ([CMFile isDirectory:p]){
			[self _searchPath:p forString:string];
		}
		
	}
	
	
	[pool release];
}

+(id)loader{
	if (_libSearcherLoader==nil){
		_libSearcherLoader = [[self alloc] initWithNibName:@"LibrarySearcher"];
	}
	return _libSearcherLoader;
}

-(IBAction)search:(id)sender{
	[NSThread detachNewThreadSelector:@selector(_search:) toTarget:self withObject:nil];
}

-(IBAction)reveal:(id)sender{
	NSArray *sel = [_arrayContr selectedObjects];
	if ([sel count]>0){
		[[NSWorkspace sharedWorkspace] selectFile:[sel objectAtIndex:0] inFileViewerRootedAtPath:@""];
	}else{
		NSBeep();
	}
}
-(IBAction)move:(id)sender{
	NSArray *sel = [_arrayContr selectedObjects];
	if ([sel count]==0){
		NSBeep();
		return;
	}
	
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseFiles:NO];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setTitle:@"Where would you like to move the selected item?"];
	if ([openPanel runModalForTypes:nil]==NSFileHandlingPanelOKButton){
		if ([CMFile moveFile:[sel objectAtIndex:0] toFolder:[openPanel filename]]){
			[_arrayContr removeObject:[sel objectAtIndex:0]];
		}else{
			[[NSAlert alertWithMessageText:@"Could not move selected files to selected destination." defaultButton:@"OK" alternateButton:@"" otherButton:@"" informativeTextWithFormat:@"The destination may not be writeable or you may not have the privilidges to modify the selected file."] runModal];
		}
	}
}
-(IBAction)copy:(id)sender{
	NSArray *sel = [_arrayContr selectedObjects];
	if ([sel count]==0){
		NSBeep();
		return;
	}
	
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseFiles:NO];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setTitle:@"Where would you like the selected item to be copied to?"];
	if ([openPanel runModalForTypes:nil]==NSFileHandlingPanelOKButton){
		if ([CMFile copyFile:[sel objectAtIndex:0] toFolder:[openPanel filename]]){
		}else{
			[[NSAlert alertWithMessageText:@"Could not copy selected files to selected destination." defaultButton:@"OK" alternateButton:@"" otherButton:@"" informativeTextWithFormat:@"The destination may not be writeable."] runModal];
		}
	}
}
-(IBAction)trash:(id)sender{
	NSArray *sel = [_arrayContr selectedObjects];
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
	if ([CMFile moveFile:[sel objectAtIndex:0] toFolder:[@"~/.Trash/" stringByExpandingTildeInPath]]){
		[_arrayContr removeObject:[sel objectAtIndex:0]];
	}else{
		[[NSAlert alertWithMessageText:@"Could not remove selected file." defaultButton:@"OK" alternateButton:@"" otherButton:@"" informativeTextWithFormat:@"You may not have the privilidges to modify the selected file."] runModal];
	}
}



@end
