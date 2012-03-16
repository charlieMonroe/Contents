//
//  CMPreferencesCleaner.m
//  LibraryLiberty
//
//  Created by alto on 9/3/09.
//  Copyright 2009 FuelCollective. All rights reserved.
//

#import "CMPreferencesCleaner.h"
#import "CMFile.h"

static CMPreferencesCleaner *_cleaner;

@implementation CMPreferencesCleaner

+(NSSize)minContentSize{
	return NSMakeSize(581, 318);
}

-(void)awakeFromNib{
	[self refresh:nil];
}

-(void)_goThroughPreferences:(id)sender{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	
	if (_loading){
		_shouldStop = YES;
		while (_shouldStop){
			usleep(500);
		}
		_shouldStop = NO;
	}
	
	_loading = YES;
	_shouldStop = NO;
	[_indicator startAnimation:nil];
	
	[_controller setContent:nil];
	
	NSString *path = [[NSString stringWithFormat:@"%@/Library/Preferences/", [_homeComputerPopup indexOfSelectedItem]==0?@"~":@""] stringByExpandingTildeInPath];
	[self _filterPath:path];
	
	_loading = NO;
	_shouldStop = NO;
	[_indicator stopAnimation:nil];
	
	[_statisticField setStringValue:[NSString stringWithFormat:@"Found %i redundant items", [[_controller content] count]]];
	
	[pool release];
}

-(void)_filterPath:(NSString*)path{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	
	if (![path isEqualToString:[CMFile resolvedAlias:path]]){
		return;
	}
	
	NSFileManager *fileMan = [NSFileManager defaultManager];
	NSArray *_items = [fileMan contentsOfDirectoryAtPath:path error:NULL];
	
	if ([_items count] == 0 || 
	    ([_items count] == 1 && [[_items objectAtIndex:0] isEqualToString:@".DS_Store"])){
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		[dict setObject:[NSNumber numberWithBool:NO] forKey:@"enabled"];
		[dict setObject:[NSDictionary dictionaryWithObjectsAndKeys:path, @"path", @"This folder is empty.", @"reason", nil] forKey:@"content"];
		[dict setObject:path forKey:@"path"];
		[_controller performSelectorOnMainThread:@selector(addObject:) withObject:dict waitUntilDone:YES];
		return;
	}
	
	int i;
	for (i=0;i<[_items count] && !_shouldStop;++i){
		NSString *p = [path stringByAppendingPathComponent:[_items objectAtIndex:i]];
		
		if ([CMFile isDirectory:p]){
			[self _filterPath:p];
		}else{
			NSDictionary *atts = [fileMan attributesOfItemAtPath:p error:nil];
			NSDate *modDate = [atts objectForKey:NSFileModificationDate];
			
			if ([[NSDate date] timeIntervalSinceDate:modDate] > 2 * 365 * 24 * 60 * 60){
				//Hasn't been modified in the past year
				NSMutableDictionary *dict = [NSMutableDictionary dictionary];
				[dict setObject:[NSNumber numberWithBool:NO] forKey:@"enabled"];
				[dict setObject:[NSDictionary dictionaryWithObjectsAndKeys:p, @"path", [NSString stringWithFormat:@"This file hasn't been modified for a long time (%i years).", (int)([[NSDate date] timeIntervalSinceDate:modDate]/(365*24*60*60))], @"reason", nil] forKey:@"content"];
				[dict setObject:p forKey:@"path"];
				[_controller performSelectorOnMainThread:@selector(addObject:) withObject:dict waitUntilDone:YES];
			}else if ([CMFile sizeOfFileIncludingResourceFork:p] == 0){
				//Empty file
				NSMutableDictionary *dict = [NSMutableDictionary dictionary];
				[dict setObject:[NSNumber numberWithBool:NO] forKey:@"enabled"];
				[dict setObject:[NSDictionary dictionaryWithObjectsAndKeys:p, @"path", @"This file is empty (has zero bytes).", @"reason", nil] forKey:@"content"];
				[dict setObject:p forKey:@"path"];
				[_controller performSelectorOnMainThread:@selector(addObject:) withObject:dict waitUntilDone:YES];
			}
		}
		
	}
	
	
	[pool release];
	
}

+(id)loader{
	if (_cleaner==nil){
		_cleaner = [[self alloc] initWithNibName:@"PrefCleaner"];
	}
	return _cleaner;
}

-(IBAction)refresh:(id)sender{
	[NSThread detachNewThreadSelector:@selector(_goThroughPreferences:) toTarget:self withObject:nil];
}

-(IBAction)reveal:(id)sender{
	NSArray *sel = [_controller selectedObjects];
	if ([sel count]>0){
		[[NSWorkspace sharedWorkspace] selectFile:[[sel objectAtIndex:0] objectForKey:@"path"] inFileViewerRootedAtPath:@""];
	}else{
		NSBeep();
	}
}
-(IBAction)trash:(id)sender{
	BOOL ask = ![[NSUserDefaults standardUserDefaults] boolForKey:@"CMLBDontDisplayTrashConfirmation"];
	if (ask){
		NSAlert *alert = [NSAlert alertWithMessageText:@"Are you sure you want to move checked item to Trash?" defaultButton:@"Move" alternateButton:@"Cancel" otherButton:@"" informativeTextWithFormat:@"You can’t undo this action."];
		[alert setShowsSuppressionButton:YES];
		if ([alert runModal]==NSAlertAlternateReturn){
			return;
		}
		[[NSUserDefaults standardUserDefaults] setBool:[[alert suppressionButton] state]==NSOnState forKey:@"CMLBDontDisplayTrashConfirmation"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	int i;
	for (i=0;i<[[_controller content] count];++i){
		if ([[[[_controller content] objectAtIndex:i] objectForKey:@"enabled"] boolValue]){
			NSString *path = [[[_controller content] objectAtIndex:i] objectForKey:@"path"];
			if (![CMFile moveFile:path toFolder:[@"~/.Trash/" stringByExpandingTildeInPath]]){
				[[NSAlert alertWithMessageText:[NSString stringWithFormat:@"Could not remove %@.", [path lastPathComponent]] defaultButton:@"OK" alternateButton:@"" otherButton:@"" informativeTextWithFormat:@"You may not have the privilidges to modify the selected file."] runModal];
			}
		}
	}
	[self refresh:nil];
	
}
-(IBAction)toggleCheck:(id)sender{
	int i;
	for (i=0;i<[[_controller selectedObjects] count];++i){
		[[[_controller selectedObjects] objectAtIndex:i] setObject:[NSNumber numberWithBool:![[[[_controller selectedObjects] objectAtIndex:i] objectForKey:@"enabled"] boolValue]] forKey:@"enabled"];
	}
}

@end
