//
//  CMRegistration.h
//  FCKit
//
//  Created by alto on 8/17/09.
//  Copyright 2009 FuelCollective. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CMRegistration : NSObject <NSCoding>
{
	NSString *_name;
	NSString *_license;
	NSString *_integrity;
	int version;
}

+(id)sharedInstance;

+(NSString*)md5Digest:(NSData*)data;
+(NSString*)iokitshortcut;
+(NSString*)integrityWithName:(NSString*)name license:(NSString*)license;

-(id)initWithName:(NSString*)name license:(NSString*)license;
-(id)initWithCoder:(NSCoder*)coder;

-(BOOL)check;

-(NSString*)name;
-(NSString*)license;

@end