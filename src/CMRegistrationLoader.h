//
//  CMRegistrationLoader.h
//  FCKit
//
//  Created by alto on 8/17/09.
//  Copyright 2009 FuelCollective. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CMContentsRegistrationLoader : NSObject {
	IBOutlet NSWindow *_window;
	IBOutlet NSButton *_laterButton;
	IBOutlet NSButton *_activateButton;
	IBOutlet NSProgressIndicator *_indicator;
	IBOutlet NSTextField *_nameField;
	IBOutlet NSTextField *_licenseField;
	
	IBOutlet NSTextField *_mainMessage;
	IBOutlet NSTextField *_infoMessage;
	
	int _ans;
}

+(int)answer;
+(void)disableLaterButton;
+(BOOL)displayWarning;
+(id)loader;
+(void)popWindow;

-(void)activateWithData:(NSData*)data;

-(IBAction)activate:(id)sender;
-(IBAction)cancel:(id)sender;
-(IBAction)buy:(id)sender;
-(IBAction)quit:(id)sender;
@end


typedef enum _CMTrialResponse {
	CMQuitResponse, CMLaterResponse, CMActivatedResponse
} CMTrialResponse;