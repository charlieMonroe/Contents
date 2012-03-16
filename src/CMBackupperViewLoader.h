//
//  CMBackupperViewLoader.h
//  LibraryLiberty
//
//  Created by alto on 9/5/09.
//  Copyright 2009 FuelCollective. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "_CMViewLoader.h"
#import "CMUninstallerCanvas.h"

@interface CMBackupperViewLoader : _CMViewLoader {
	IBOutlet NSArrayController *_controller;
	IBOutlet CMUninstallerCanvas *_canvas;
}

+(NSSize)minContentSize;

+(id)loader;

-(BOOL)containsPath:(NSString*)path;
-(void)addPath:(NSString*)path;
-(id)objectForPath:(NSString*)path;

-(IBAction)add:(id)sender;
-(IBAction)remove:(id)sender;

-(IBAction)backup:(id)sender;
-(IBAction)restore:(id)sender;

@end
