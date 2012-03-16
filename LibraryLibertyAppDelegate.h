//
//  LibraryLibertyAppDelegate.h
//  LibraryLiberty
//
//  Created by Krystof Vasa on 8/22/09.
//  Copyright 2009 FuelCollective, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LibraryLibertyAppDelegate : NSObject <NSToolbarDelegate> {
	IBOutlet NSWindow *window;
	IBOutlet NSWindow *_helpWindow;
}

-(void)setMainWindowContentView:(NSView*)view;

-(NSWindow*)window;

-(IBAction)selectBrowser:(id)sender;
-(IBAction)selectSearcher:(id)sender;
-(IBAction)selectPrefCleaner:(id)sender;
-(IBAction)selectUninstaller:(id)sender;
-(IBAction)selectInstaller:(id)sender;
-(IBAction)selectBackupper:(id)sender;

-(IBAction)showHelp:(id)sender;

@end
