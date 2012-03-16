//
//  CMRegistration.m
//  FCKit
//
//  Created by alto on 8/17/09.
//  Copyright 2009 FuelCollective. All rights reserved.
//

#import "CMRegistration.h"
#import "md5.h"

static CMRegistration *_sharedReg;

@implementation CMRegistration

+(NSString*)md5Digest:(NSData*)data{
	isc_md5_t       context;
	unsigned char   digest[ ISC_MD5_DIGESTLENGTH];
	
	isc_md5_init( &context);
	isc_md5_update( &context, (const unsigned char *) [data bytes], [data length]);
	isc_md5_final( &context, digest);
	
	NSString *str = [[NSData dataWithBytes:digest length:ISC_MD5_DIGESTLENGTH] description];
	NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@" ><"];
	str = [str stringByTrimmingCharactersInSet:charSet];
	
	int i;
	int len = [str length];
	int spaces = 0;
	int removed = 0;
	unichar newStr[len];
	for (i=0;i<len;++i){
		if ([str characterAtIndex:i] == ' '){
			++removed;
			++spaces;
		}else{
			newStr[i-removed] = [str characterAtIndex:i];
		}
	}
	
	return [NSString stringWithCharacters:newStr length:len-spaces];
	
}
+(NSString*)iokitshortcut{
	CFStringRef serialNumber = NULL;
	io_service_t platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"));
	if (platformExpert){
		CFTypeRef serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert, CFSTR(kIOPlatformSerialNumberKey), kCFAllocatorDefault, 0);
		serialNumber = (CFStringRef)serialNumberAsCFString;
		IOObjectRelease(platformExpert);
	}
	NSString *result;
	if (serialNumber){
		result = [(NSString*)serialNumber autorelease];
	}else{
		result = @"unknown";
	}
	
	return result;
}
+(NSString*)integrityWithName:(NSString*)name license:(NSString*)license{
	NSString *compSN = [CMRegistration iokitshortcut];
	NSString *tmp = [NSString stringWithFormat:@"%@%@%@", name, license, compSN];
	
	const char *utfString = [tmp UTF8String];
	int length = strlen(utfString);
	char *result = malloc(length * sizeof(char));
	
	int i;
	for (i=0; i<length; ++i){
		char c1, c2;
		if (i == length - 1){
			//The last odd char
			c1 = utfString[i];
			c2 = ' ';
		}else{
			c1 = utfString[i];
			c2 = utfString[i+1];
		}
		char r1, r2;
		r1 = (char)(((c1+c2)*pi)/2);
		r2 = c1 * r1;
		
		result[i] = r1;
		if (i!=length-1){
			result[i+1] = r2;
		}
	}
	
	NSString *_resStr = [CMRegistration md5Digest:[NSData dataWithBytes:result length:length]];
	free(result);
	return _resStr;
	
}

+(id)sharedInstance{
	return _sharedReg;
}

-(void)encodeWithCoder:(NSKeyedArchiver *)aCoder{
	[aCoder encodeObject:_name forKey:@"_name"];
	[aCoder encodeObject:_license forKey:@"_license"];
	[aCoder encodeObject:_integrity forKey:@"_integrity"];
	[aCoder encodeObject:[NSNumber numberWithInt:version] forKey:@"version"];
}
-(id)initWithCoder:(NSKeyedUnarchiver *)coder{
	if ((self = [super init])!=nil){
		
		_name = [[coder decodeObjectForKey:@"_name"] retain];
		_license = [[coder decodeObjectForKey:@"_license"] retain];
		_integrity = [[coder decodeObjectForKey:@"_integrity"] retain];
		version = [[coder decodeObjectForKey:@"version"] intValue];
		
		if (_sharedReg != self){
			[_sharedReg release];
			_sharedReg = [self retain];
		}
	}
	return self;
}
-(id)initWithName:(NSString *)name license:(NSString *)license{
	if ((self = [super init])!=nil){
				
		_license = [license retain];
		_name = [name retain];
		_integrity = [[CMRegistration integrityWithName:name license:license] retain];
		version = 1;
		
		if (_sharedReg != self){
			[_sharedReg release];
			_sharedReg = [self retain];
		}
		
	}
	return self;
}

-(BOOL)check{
	NSString *newInteg = [CMRegistration integrityWithName:_name license:_license];
	BOOL res = [newInteg isEqualToString:_integrity];
	
	if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] intValue]%2 != 0){
		res = !res;
	}
	
	return res;
}

-(NSString*)name{
	return _name;
}
-(NSString*)license{
	return _license;
}
@end