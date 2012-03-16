//
//  CMUninstallerViewLoader.m
//  LibraryLiberty
//
//  Created by alto on 9/3/09.
//  Copyright 2009 FuelCollective. All rights reserved.
//

#import "CMUninstallerViewLoader.h"
#import "CMFile.h"

static CMUninstallerViewLoader *_uninstaller;

@interface NSMutableArray (NilSafeMethods)
-(void)addAnyObject:(id)obj;
@end
@implementation NSMutableArray (NilSafeMethods)

-(void)addAnyObject:(id)obj{
	if (obj!=nil){
		[self addObject:obj];
	}
}

@end



@implementation CMUninstallerViewLoader

+(NSSize)minContentSize{
	return NSMakeSize(572, 341);
}

-(void)_search:(id)sender{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	
	[[self view] setInformativeText:@"Searching for relevant files in Application Support..."];
	[self _searchAtPath:@"/Library/Application Support"];
	[self _searchAtPath:[@"~/Library/Application Support" stringByExpandingTildeInPath]];
	
	[[self view] setInformativeText:@"Searching for relevant files in Caches..."];
	[self _searchAtPath:@"/Library/Caches"];
	[self _searchAtPath:[@"~/Library/Caches" stringByExpandingTildeInPath]];
	[self _searchAtPath:[@"~/Library/Caches/Metadata" stringByExpandingTildeInPath]];
	
	[[self view] setInformativeText:@"Searching for relevant files in Contextual Menu Items..."];
	[self _searchAtPath:@"/Library/Contextual Menu Items"];
	[self _searchAtPath:[@"~/Library/Contextual Menu Items" stringByExpandingTildeInPath]];
	
	[[self view] setInformativeText:@"Searching for relevant files in Documentation..."];
	[self _searchAtPath:@"/Library/Documentation"];
	[self _searchAtPath:[@"~/Library/Documentation" stringByExpandingTildeInPath]];
	
	[[self view] setInformativeText:@"Searching for relevant files in Frameworks..."];
	[self _searchAtPath:@"/Library/Frameworks"];
	[self _searchAtPath:[@"~/Library/Frameworks" stringByExpandingTildeInPath]];
	
	[[self view] setInformativeText:@"Searching for relevant files in Input Managers..."];
	[self _searchAtPath:@"/Library/InputManagers"];
	[self _searchAtPath:[@"~/Library/InputManagers" stringByExpandingTildeInPath]];
	
	[[self view] setInformativeText:@"Searching for relevant files in Internet Plug-Ins..."];
	[self _searchAtPath:@"/Library/Internet Plug-Ins"];
	[self _searchAtPath:[@"~/Library/Internet Plug-Ins" stringByExpandingTildeInPath]];
	
	[[self view] setInformativeText:@"Searching for relevant files in Logs..."];
	[self _searchAtPath:@"/Library/Logs"];
	[self _searchAtPath:[@"~/Library/Logs" stringByExpandingTildeInPath]];
	
	[[self view] setInformativeText:@"Searching for relevant files in Preference Panes..."];
	[self _searchAtPath:@"/Library/PreferencePanes"];
	[self _searchAtPath:[@"~/Library/PreferencePanes" stringByExpandingTildeInPath]];
	
	[[self view] setInformativeText:@"Searching for relevant files in Preferences..."];
	[self _searchAtPath:@"/Library/Preferences"];
	[self _searchAtPath:[@"~/Library/Preferences" stringByExpandingTildeInPath]];
	
	[[self view] setInformativeText:@"Searching for relevant files in QuickLook..."];
	[self _searchAtPath:@"/Library/QuickLook"];
	[self _searchAtPath:[@"~/Library/QuickLook" stringByExpandingTildeInPath]];
	
	[[self view] setInformativeText:@"Searching for relevant files in Library..."];
	[self _searchAtPath:@"/Library/"];
	[self _searchAtPath:[@"~/Library/" stringByExpandingTildeInPath]];
	
	[[self view] setInformativeText:@"Searching for relevant files in Documents..."];
	[self _searchAtPath:[@"~/Documents/" stringByExpandingTildeInPath]];
	
	NSDictionary *safPrefs = [NSDictionary dictionaryWithContentsOfFile:[@"~/Library/Preferences/com.apple.Safari.plist" stringByExpandingTildeInPath]];
	[[self view] setInformativeText:@"Searching for relevant files in Downloads..."];
	[self _searchAtPath:[[safPrefs objectForKey:@"DownloadsPath"] stringByExpandingTildeInPath]];
	
	[(CMUninstallerCanvas*)[self view] setMode:2];
	
	[pool release];
}

-(void)_searchAtPath:(NSString*)searchedPath{
	if (![[NSFileManager defaultManager] fileExistsAtPath:searchedPath]){
		return;
	}
	
	NSString *compName = nil;
	if ([_strs count]>0){
		NSString *tmp = [_strs objectAtIndex:0];
		NSArray *comps = [tmp componentsSeparatedByString:@"."];
		if ([comps count]>1){
			compName = [comps objectAtIndex:1];
		}
	}
	
	NSArray *conts = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:searchedPath error:NULL];
	
	int i;
	for (i=0;i<[conts count];++i){
		NSString *item = [conts objectAtIndex:i];
		
		if (compName != nil && [item rangeOfString:compName options:NSCaseInsensitiveSearch].location!=NSNotFound){
			[self _searchAtPath:[searchedPath stringByAppendingPathComponent:item]];
		}
		
		int o;
		for (o=0;o<[_strs count];++o){
			if ([item rangeOfString:[_strs objectAtIndex:o] options:NSCaseInsensitiveSearch].location!=NSNotFound){
				[self performSelectorOnMainThread:@selector(addPathToResults:) withObject:[searchedPath stringByAppendingPathComponent:item] waitUntilDone:YES];
				break;
			}
		}
	}
}

-(void)addPathToResults:(NSString*)path{
	NSDictionary *bundleInfo = [NSDictionary dictionaryWithContentsOfFile:[[_path stringByAppendingPathComponent:@"Contents"] stringByAppendingPathComponent:@"Info.plist"]];
	NSString *bundleIdent = [bundleInfo objectForKey:@"CFBundleIdentifier"];
	if (bundleIdent!=nil){
		NSString *lpc = [path lastPathComponent];
		if ([lpc hasPrefix:@"com."] && ![lpc hasPrefix:bundleIdent]){
			return;
		}
	}
	
	if ([self containsPath:path]){
		return;
	}
	
	[_controller addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"enabled", path, @"path", nil]];
}

-(BOOL)containsPath:(NSString*)path{
	int i;
	for (i=0;i<[[_controller content] count];++i){
		if ([[[[_controller content] objectAtIndex:i] objectForKey:@"path"] isEqualToString:path]){
			return YES;
		}
	}
	return NO;
}

-(IBAction)back:(id)sender{
	[(CMUninstallerCanvas*)[self view] setMode:0];
}

+(id)loader{
	if (_uninstaller==nil){
		_uninstaller = [[self alloc] initWithNibName:@"Uninstaller"];
	}
	return _uninstaller;
}

-(void)loadItem:(NSString*)path{
	if (path == _path){
		return;
	}
	[_path release];
	_path = [path retain];
	
	NSDictionary *bundleInfo = [NSDictionary dictionaryWithContentsOfFile:[[_path stringByAppendingPathComponent:@"Contents"] stringByAppendingPathComponent:@"Info.plist"]];
	if ([[bundleInfo objectForKey:@"CFBundleIdentifier"] hasPrefix:@"com.apple."]){
		if ([[NSAlert alertWithMessageText:@"This application seems to be an Apple application. Do you wish to continue?" defaultButton:@"Continue" alternateButton:@"Cancel" otherButton:@"" informativeTextWithFormat:@"This application might have come with the system and uninstalling it could damage your system. Continuing, however, will only list the files and will not delete any files without your permission."] runModal] == NSAlertAlternateReturn){
			//Abort!!!
			[(CMUninstallerCanvas*)[self view] setMode:0];
			return;
		}
	}
	
	[_controller setContent:nil];
	
	[_strs release];
	_strs = [[NSMutableArray array] retain];
	
	[_strs addAnyObject:[bundleInfo objectForKey:@"CFBundleIdentifier"]];
	[_strs addAnyObject:[bundleInfo objectForKey:@"CFBundleName"]];
	[_strs addAnyObject:[[_path lastPathComponent] stringByDeletingPathExtension]];
	
	[self addPathToResults:path];
	
	[NSThread detachNewThreadSelector:@selector(_search:) toTarget:self withObject:nil];
}

-(IBAction)uninstall:(id)sender{
	if ([[NSAlert alertWithMessageText:@"Are you sure you want to move all of the checked items to trash?" defaultButton:@"Continue" alternateButton:@"Cancel" otherButton:@"" informativeTextWithFormat:@"This action can't be undone. No files will be deleted."] runModal] == NSAlertAlternateReturn){
		//Abort!!!
		return;
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
	
	[(CMUninstallerCanvas*)[self view] setMode:0];
}

@end
