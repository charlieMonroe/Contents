//
//  CMBackupperViewLoader.m
//  LibraryLiberty
//
//  Created by Krystof Vasa on 9/5/09.
//  Copyright 2009 FuelCollective, LLC. All rights reserved.
//

#import "CMBackupperViewLoader.h"
#import "CMFile.h"
#import "NSData+NSDataAdditions.h"

static CMBackupperViewLoader *_backupper;

@implementation CMBackupperViewLoader

+(NSSize)minContentSize{
	return NSMakeSize(581, 371);
}

-(void)_saveDefaults{
	NSMutableArray *enabledItems = [NSMutableArray array];
	NSMutableArray *customItems = [NSMutableArray array];
	
	int i;
	for (i=0;i<[[_controller content] count];++i){
		NSString *p = [[[[[_controller content] objectAtIndex:i] objectForKey:@"content"] objectForKey:@"path"] stringByExpandingTildeInPath];
		if ([[[[_controller content] objectAtIndex:i] objectForKey:@"enabled"] boolValue]){
			[enabledItems addObject:p];
		}
	}
	for (i=0;i<[[_controller content] count];++i){
		NSString *p = [[[[_controller content] objectAtIndex:i] objectForKey:@"content"] objectForKey:@"path"];
		if (![p hasPrefix:@"~"]){
			[customItems addObject:[p stringByExpandingTildeInPath]];
		}
	}
	
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	[defs setObject:enabledItems forKey:@"BackupperEnabledItems"];
	[defs setObject:customItems forKey:@"BackupperCustomFiles"];
	[defs synchronize];
	
}

+(id)loader{
	if (_backupper==nil){
		_backupper = [[self alloc] initWithNibName:@"Backupper"];
	}
	return _backupper;
}
-(void)addPath:(NSString*)path{
	if (![self containsPath:path]){
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		[dict setObject:[NSNumber numberWithBool:NO] forKey:@"enabled"];
		NSMutableDictionary *content = [NSMutableDictionary dictionary];
		[content setObject:path forKey:@"path"];
		[content setObject:[path lastPathComponent] forKey:@"name"];
		[content setObject:path forKey:@"description"];
		if ([[NSFileManager defaultManager] fileExistsAtPath:path]){
			[content setObject:[[NSWorkspace sharedWorkspace] iconForFile:path] forKey:@"icon"];
		}
		[dict setObject:content forKey:@"content"];
		[_controller addObject:dict];
	}
}

-(void)awakeFromNib{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_saveDefaults) name:NSApplicationWillTerminateNotification object:nil];
	
	NSArray *array = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BackupSources" ofType:@"plist"]];
	
	int i;
	for (i=0;i<[array count];++i){
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		[dict setObject:[NSNumber numberWithBool:NO] forKey:@"enabled"];
		[dict setObject:[array objectAtIndex:i] forKey:@"content"];
		[_controller addObject:dict];
	}
	
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	NSArray *customFiles = [defs objectForKey:@"BackupperCustomFiles"];
	for (i=0;i<[customFiles count];++i){
		[self addPath:[customFiles objectAtIndex:i]];
	}
	
	NSArray *enabledItems = [defs objectForKey:@"BackupperEnabledItems"];
	for (i=0;i<[enabledItems count];++i){
		[[self objectForPath:[enabledItems objectAtIndex:i]] setObject:[NSNumber numberWithBool:YES] forKey:@"enabled"];
	}
	
}

-(BOOL)containsPath:(NSString*)path{
	return [self objectForPath:path]!=nil;
}

-(id)objectForPath:(NSString*)path{
	int i;
	for (i=0;i<[[_controller content] count];++i){
		NSString *p = [[[[[_controller content] objectAtIndex:i] objectForKey:@"content"] objectForKey:@"path"] stringByExpandingTildeInPath];
		if ([p isEqualToString:path]){
			return [[_controller content] objectAtIndex:i];
		}
	}
	return nil;
}

-(IBAction)add:(id)sender{
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setCanChooseFiles:YES];
	[panel setCanChooseDirectories:YES];
	if ([panel runModalForTypes:[NSArray array]]==NSFileHandlingPanelOKButton){
		if ([self containsPath:[panel filename]]){
			[[NSAlert alertWithMessageText:@"This file is already on the list." defaultButton:@"OK" alternateButton:@"" otherButton:@"" informativeTextWithFormat:@""] beginSheetModalForWindow:[self window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
			return;
		}
		[self addPath:[panel filename]];
		[[self objectForPath:[panel filename]] setObject:[NSNumber numberWithBool:YES] forKey:@"enabled"];
	}
}

-(IBAction)remove:(id)sender{
	NSArray *sel = [_controller selectedObjects];
	if (sel == nil || [sel count]==0){
		NSBeep();
		return;
	}
	NSString *path = [[[sel objectAtIndex:0] objectForKey:@"content"] objectForKey:@"path"];
	if ([path hasPrefix:@"~"]){
		[[NSAlert alertWithMessageText:@"You cannot remove a built-in source." defaultButton:@"OK" alternateButton:@"" otherButton:@"" informativeTextWithFormat:@"If you don't want it to be backed up, just uncheck the check box next to it."] beginSheetModalForWindow:[self window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
		return;
	}
	[_controller removeObject:[sel objectAtIndex:0]];
}

-(IBAction)backup:(id)sender{
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setCanChooseFiles:NO];
	[panel setCanChooseDirectories:YES];
	[panel setTitle:@"Choose a directory to back up selected files to."];
	if ([panel runModalForTypes:[NSArray array]]!=NSFileHandlingPanelOKButton){
		return;
	}
	NSString *path = [panel filename];
	if ([[NSFileManager defaultManager] fileExistsAtPath:[path stringByAppendingPathComponent:@"FCBackup"]]){
		if ([[NSAlert alertWithMessageText:@"A previous backup already exists at selected location. Continuing will replace the old backup with a new one." defaultButton:@"Continue" alternateButton:@"Cancel" otherButton:@"" informativeTextWithFormat:@"The old backup will be deleted."] runModal]==NSAlertAlternateReturn){
			return;
		}
	}
	
	[_canvas setMode:1];
	[_canvas setTitle:@"Backing up files..."];
	[_canvas setInformativeText:nil];
	
	[_canvas setHidden:NO];
	
	[NSThread detachNewThreadSelector:@selector(_backup:) toTarget:self withObject:[[path retain] autorelease]];
}

-(void)_backup:(NSString*)destPath{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	[destPath retain];
	
	BOOL usesTempLocation = NO;
	NSString *backupDestination = [destPath stringByAppendingPathComponent:@"FCBackup"];
	
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:backupDestination]){
		usesTempLocation = YES;
		backupDestination = [destPath stringByAppendingPathComponent:@"._FCBackup"];
	}
	
	[[NSFileManager defaultManager] createDirectoryAtPath:backupDestination withIntermediateDirectories:YES attributes:nil error:nil];
	if (![[NSFileManager defaultManager] fileExistsAtPath:backupDestination]){
		[[NSAlert alertWithMessageText:@"Could not create backup destination at selected location." defaultButton:@"OK" alternateButton:@"" otherButton:@"" informativeTextWithFormat:@"You might not have the permission to modify the destination."] runModal];
		
		[_canvas setHidden:YES];
		[_canvas display];
		[[self view] setNeedsDisplay:YES];
		
		[destPath release];
		[pool release];
		return;
	}
	
	int i;
	for (i=0;i<[[_controller content] count];++i){
		NSDictionary *item = [[_controller content] objectAtIndex:i];
		if ([[item objectForKey:@"enabled"] boolValue]){
			[_canvas setInformativeText:[NSString stringWithFormat:@"Copying \"%@\"", [[item objectForKey:@"content"] objectForKey:@"name"]]];
			
			NSString *path = [[item objectForKey:@"content"] objectForKey:@"path"];
			if ([path hasPrefix:@"~"]){
				//Builtin categories -> just copy
				if (![CMFile copyFile:[[[item objectForKey:@"content"] objectForKey:@"path"] stringByExpandingTildeInPath] toFolder:backupDestination]){
					[[NSAlert alertWithMessageText:[NSString stringWithFormat:@"Could not backup \"%@\".", [[item objectForKey:@"content"] objectForKey:@"name"]] defaultButton:@"OK" alternateButton:@"" otherButton:@"" informativeTextWithFormat:@"You might not have the permission to read the source or modify the destination."] runModal];
				}
			}else{
				//A custom file -> modify name.
				NSString *newName = [NSString stringWithFormat:@"%@ from %@", [path lastPathComponent], [[path dataUsingEncoding:NSUTF8StringEncoding] md5Digest]];
				NSString *targetPath = [backupDestination stringByAppendingPathComponent:newName];
				if (![CMFile _copyFileWithoutAuthentication:path toPath:targetPath]){
					if (![CMFile _copyFileWithAuthentication:path toPath:targetPath]){
						[[NSAlert alertWithMessageText:[NSString stringWithFormat:@"Could not backup \"%@\".", [[item objectForKey:@"content"] objectForKey:@"name"]] defaultButton:@"OK" alternateButton:@"" otherButton:@"" informativeTextWithFormat:@"You might not have the permission to read the source or modify the destination."] runModal];
					}
				}
			}
			
			
		}
	}
	
	if (usesTempLocation){
		if ([CMFile removeFile:[destPath stringByAppendingPathComponent:@"FCBackup"]]){
			if (![CMFile _moveFileWithoutAuthentication:backupDestination toPath:[destPath stringByAppendingPathComponent:@"FCBackup"]]){
				if (![CMFile _moveFileWithAuthentication:backupDestination toPath:[destPath stringByAppendingPathComponent:@"FCBackup"]]){
					[CMFile removeFile:backupDestination];
					[[NSAlert alertWithMessageText:@"Could not replace old backup." defaultButton:@"OK" alternateButton:@"" otherButton:@"" informativeTextWithFormat:@"You might not have the permission to modify the old backup."] runModal];
				}
			}
		}else{
			[CMFile removeFile:backupDestination];
			[[NSAlert alertWithMessageText:@"Could not replace old backup." defaultButton:@"OK" alternateButton:@"" otherButton:@"" informativeTextWithFormat:@"You might not have the permission to modify the old backup."] runModal];
		}
	}
	
	[_canvas setHidden:YES];
	[_canvas display];
	[[self view] setNeedsDisplay:YES];
	
	[destPath release];
	[pool release];
}

-(IBAction)restore:(id)sender{
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setCanChooseFiles:NO];
	[panel setCanChooseDirectories:YES];
	[panel setTitle:@"Choose a directory with the backup."];
	if ([panel runModalForTypes:[NSArray array]]!=NSFileHandlingPanelOKButton){
		return;
	}
	NSString *path = [panel filename];
	if (![[path lastPathComponent] isEqualToString:@"FCBackup"]){
		path = [path stringByAppendingPathComponent:@"FCBackup"];
	}
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]){
		[[NSAlert alertWithMessageText:@"Cannot find backup at selected location." defaultButton:@"OK" alternateButton:@"" otherButton:@"" informativeTextWithFormat:@"Cannot proceed."] runModal];
		return;
	}
	
	[_canvas setMode:1];
	[_canvas setTitle:@"Restoring files..."];
	[_canvas setInformativeText:nil];
	
	[_canvas setHidden:NO];
	
	[NSThread detachNewThreadSelector:@selector(_restore:) toTarget:self withObject:[[path retain] autorelease]];
}

-(void)_restore:(NSString*)destPath{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	[destPath retain];
		
	int i;
	for (i=0;i<[[_controller content] count];++i){
		NSDictionary *item = [[_controller content] objectAtIndex:i];
		if ([[item objectForKey:@"enabled"] boolValue]){
			
			[_canvas setInformativeText:[NSString stringWithFormat:@"Copying \"%@\"", [[item objectForKey:@"content"] objectForKey:@"name"]]];
			
			NSString *path = [[item objectForKey:@"content"] objectForKey:@"path"];
			
			NSString *sourcePath = nil;
			
			if ([path hasPrefix:@"~"]){
				path = [path stringByExpandingTildeInPath];
				sourcePath = [destPath stringByAppendingPathComponent:[path lastPathComponent]];
			}else{
				//A custom file -> modify name.
				NSString *newName = [NSString stringWithFormat:@"%@ from %@", [path lastPathComponent], [[path dataUsingEncoding:NSUTF8StringEncoding] md5Digest]];
				sourcePath = [destPath stringByAppendingPathComponent:newName];
			}
			
			if (![[NSFileManager defaultManager] fileExistsAtPath:sourcePath]){
				[[NSAlert alertWithMessageText:[NSString stringWithFormat:@"Could not restore \"%@\".", [[item objectForKey:@"content"] objectForKey:@"name"]] defaultButton:@"OK" alternateButton:@"" otherButton:@"" informativeTextWithFormat:@"Cannot find backup for this item."] runModal];
				continue;
			}
			
			NSString *targetPath = [[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:[NSString stringWithFormat:@"._%@", [sourcePath lastPathComponent]]];
			
			if (![CMFile _copyFileWithoutAuthentication:sourcePath toPath:targetPath]){
				if (![CMFile _copyFileWithAuthentication:sourcePath toPath:targetPath]){
					[[NSAlert alertWithMessageText:[NSString stringWithFormat:@"Could not restore \"%@\".", [[item objectForKey:@"content"] objectForKey:@"name"]] defaultButton:@"OK" alternateButton:@"" otherButton:@"" informativeTextWithFormat:@"You might not have the permission to read the source or modify the destination."] runModal];
					continue;
				}
			}
			
			if (![CMFile removeFile:path]){
				[CMFile removeFile:targetPath];
				[[NSAlert alertWithMessageText:[NSString stringWithFormat:@"Could not restore \"%@\".", [[item objectForKey:@"content"] objectForKey:@"name"]] defaultButton:@"OK" alternateButton:@"" otherButton:@"" informativeTextWithFormat:@"Couldn't replace original files."] runModal];
				continue;
			}
			
			if (![CMFile _moveFileWithoutAuthentication:targetPath toPath:path]){
				if (![CMFile _moveFileWithAuthentication:targetPath toPath:path]){
					[CMFile removeFile:targetPath];
					[[NSAlert alertWithMessageText:[NSString stringWithFormat:@"Could not restore \"%@\".", [[item objectForKey:@"content"] objectForKey:@"name"]] defaultButton:@"OK" alternateButton:@"" otherButton:@"" informativeTextWithFormat:@"Couldn't move copied files."] runModal];
					continue;
				}
			}
			
		}
	}
		
	[[self window] flushWindow];
	
	[_canvas setHidden:YES];
	[_canvas setNeedsDisplay:YES];
	[[self view] setNeedsDisplay:YES];
	
	[destPath release];
	[pool release];
}

@end
