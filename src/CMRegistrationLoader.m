//
//  CMRegistrationLoader.m
//  FCKit
//
//  Created by alto on 8/17/09.
//  Copyright 2009 FuelCollective. All rights reserved.
//

#import "CMRegistrationLoader.h"
#import "FCRegistration.h"

static CMContentsRegistrationLoader *_trialLoader;

@implementation CMContentsRegistrationLoader

-(void)_activate{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	
	NSString *urlStr = [NSString stringWithFormat:@"https://fuelcollective.com/license/redeem/%@/%@", [_nameField stringValue], [_licenseField stringValue]];
	urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
	
	NSError *err = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&err];
	
	[self performSelectorOnMainThread:@selector(activateWithData:) withObject:err!=nil?nil:data waitUntilDone:NO];
	
	
	[pool release];
}

-(IBAction)activate:(id)sender{
	if (![[_licenseField stringValue] hasPrefix:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleSignature"]]){
		[self activateWithData:[NSData dataWithBytes:(const char*)"-" length:1]];
		return;
	}
	[_activateButton setEnabled:NO];
	[NSThread detachNewThreadSelector:@selector(_activate) toTarget:self withObject:nil];
}

-(void)activateWithData:(NSData*)data{
	NSString *appName = [[NSProcessInfo processInfo] processName];
	
	if (data == nil || [data length]==0){
		[[NSAlert alertWithMessageText:@"There was an error connecting to the server!" defaultButton:@"OK" alternateButton:@"" otherButton:@"" informativeTextWithFormat:@"Please, check your connection to the Internet and try again."] runModal];
	}else{
		char reg = ((const char*)[data bytes])[0];
		if (reg == '0'){
			[[NSAlert alertWithMessageText:@"The license or name you have enter is not valid." defaultButton:@"OK" alternateButton:@"" otherButton:@"" informativeTextWithFormat:@"Please check your activation email and re-enter your information."] runModal];
		}else if (reg == '1'){
			[[NSAlert alertWithMessageText:[NSString stringWithFormat:@"Thank you for activating %@!", appName] defaultButton:@"Continue" alternateButton:@"" otherButton:@"" informativeTextWithFormat:[NSString stringWithFormat:@"The activation process succeeded. Your copy of %@ is now registered.", appName]] runModal];
			
			FCRegistrationWrapper *reg = [[[FCRegistrationWrapper alloc] initWithName:[_nameField stringValue] license:[_licenseField stringValue]] autorelease];
			[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:reg] forKey:[FCRegistrationWrapper iokitshortcut]];
			[[NSUserDefaults standardUserDefaults] synchronize];			
			
			_ans = CMActivatedResponse;
			[NSApp stopModal];
			[_window orderOut:nil];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"CMApplicationGotRegistered" object:nil];
		}else if (reg == 'A'){
			[[NSAlert alertWithMessageText:@"This license has been activated too many times." defaultButton:@"OK" alternateButton:@"" otherButton:@"" informativeTextWithFormat:@"If you feel this is an error, please contact us at support@fuelcollective.com."] runModal];
		}else if (reg == 'X'){
			[[NSAlert alertWithMessageText:@"Sorry, but this license has been banned." defaultButton:@"OK" alternateButton:@"" otherButton:@"" informativeTextWithFormat:@"We worked really hard on this app and so if you would like we'll give you 5% off for your troubles. Just enter the code 'itriedstealingthisappandnowifeelbad' at checkout."] runModal];
		}else{
			[[NSAlert alertWithMessageText:@"The license or name you have enter is not valid." defaultButton:@"OK" alternateButton:@"" otherButton:@"" informativeTextWithFormat:@"Please check your activation email and re-enter your information."] runModal];
		}
	}
	[_activateButton setEnabled:YES];
}

+(int)answer{
	[CMContentsRegistrationLoader loader];
	return _trialLoader->_ans;
}

-(IBAction)buy:(id)sender{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://fuelcollective.com/store/"]];
}

-(IBAction)cancel:(id)sender{
	_ans = CMLaterResponse;
	[NSApp stopModal];
	[_window orderOut:nil];
}

+(void)disableLaterButton{
	[CMContentsRegistrationLoader loader];
	[_trialLoader->_laterButton setHidden:YES];
}

+(BOOL)displayWarning{
	
	FCRegistrationWrapper *reg = [FCRegistrationWrapper sharedInstance];
	if (reg==nil && [[NSUserDefaults standardUserDefaults] objectForKey:[FCRegistrationWrapper iokitshortcut]]!=nil){
		reg = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:[FCRegistrationWrapper iokitshortcut]]];
	}
	
	if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] intValue]%2 != 0 && reg == nil){
		return YES;
	}
	return [reg check];
	
}

+(id)loader{
	if (_trialLoader==nil){
		NSString *appName = [[NSProcessInfo processInfo] processName];
		_trialLoader = [[self alloc] init];
		
		NSNib *nib = [[[NSNib alloc] initWithNibNamed:@"Trial" bundle:[NSBundle mainBundle]] autorelease];
		[nib instantiateNibWithOwner:_trialLoader topLevelObjects:nil];
		
		[_trialLoader->_mainMessage setStringValue:[NSString stringWithFormat:[_trialLoader->_mainMessage stringValue], appName]];
		[_trialLoader->_infoMessage setStringValue:[NSString stringWithFormat:[_trialLoader->_infoMessage stringValue], appName, appName]];
	}
	return _trialLoader;
}

+(void)popWindow{
	[CMContentsRegistrationLoader loader];
	
	[NSApp activateIgnoringOtherApps:YES];
	
	NSWindow *w = _trialLoader->_window;
	[w setLevel:NSModalPanelWindowLevel];
	
	if ([w isVisible]){
		return;
	}
	[w center];
	[w makeKeyAndOrderFront:nil];
	[NSApp runModalForWindow:w];
}

-(IBAction)quit:(id)sender{
	_ans = CMQuitResponse;
	[NSApp stopModal];
	[NSApp terminate:nil];
}
@end
