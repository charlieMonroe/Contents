//
//  CMUninstallerViewLoader.h
//  LibraryLiberty
//
//  Created by Krystof Vasa on 9/3/09.
//  Copyright 2009 FuelCollective, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "_CMViewLoader.h"
#import "CMUninstallerCanvas.h"

@interface CMUninstallerViewLoader : _CMViewLoader {
	IBOutlet NSArrayController *_controller;
	
	NSString *_path;
	NSMutableArray *_strs;
}

+(NSSize)minContentSize;

-(IBAction)back:(id)sender;
-(IBAction)uninstall:(id)sender;

-(BOOL)containsPath:(NSString*)path;
-(void)loadItem:(NSString*)path;

-(void)_searchAtPath:(NSString*)searchedPath;

-(void)addPathToResults:(NSString*)path;

+(id)loader;

@end
