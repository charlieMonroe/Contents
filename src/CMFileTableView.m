//
//  CMFileTableView.m
//  LibraryLiberty
//
//  Created by Krystof Vasa on 8/25/09.
//  Copyright 2009 FuelCollective, LLC. All rights reserved.
//

#import "CMFileTableView.h"

@implementation CMFileTableView

-(void)awakeFromNib{
	[self setDataSource:self];
	[self setDoubleAction:@selector(open:)];
	[self setTarget:self];
}

-(void)keyDown:(NSEvent *)theEvent{
	NSDictionary *item = nil;
	if ([[_controller selectedObjects] count]>0){
		item = [[_controller selectedObjects] objectAtIndex:0];
	}

	if (([theEvent keyCode]==36 && !([theEvent modifierFlags]&NSCommandKeyMask)) || (([theEvent modifierFlags]&NSCommandKeyMask) && [theEvent keyCode]==125)){
		//Enter or Command-Down
		[[NSWorkspace sharedWorkspace] openFile:[item isKindOfClass:[NSDictionary class]]?[item objectForKey:@"path"]:item];
		return;
	}else if ([theEvent keyCode]==36 && [theEvent modifierFlags]&NSCommandKeyMask){
		//Command-Enter
		[[NSWorkspace sharedWorkspace] selectFile:[item isKindOfClass:[NSDictionary class]]?[item objectForKey:@"path"]:item inFileViewerRootedAtPath:@""];
		return;
	}
	[super keyDown:theEvent];
}
-(void)open:(id)sender{
	NSDictionary *item = nil;
	if ([[_controller selectedObjects] count]>0){
		item = [[_controller selectedObjects] objectAtIndex:0];
	}
	[[NSWorkspace sharedWorkspace] openFile:[item isKindOfClass:[NSDictionary class]]?[item objectForKey:@"path"]:item];
}
@end
