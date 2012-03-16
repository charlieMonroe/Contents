//
//  CMFileTableView.h
//  LibraryLiberty
//
//  Created by Krystof Vasa on 8/25/09.
//  Copyright 2009 FuelCollective, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CMFileTableView : NSTableView <NSTableViewDelegate, NSTableViewDataSource> {
	IBOutlet NSArrayController *_controller;
}

@end
