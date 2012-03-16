//
//  NSData+NSDataAdditions.m
//  Contents
//
//  Created by Charlie Monroe on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSData+NSDataAdditions.h"
#import "md5.h"

@implementation NSData (NSDataAdditions)
-(NSString *)md5Digest{
	isc_md5_t       context;
	unsigned char   digest[ ISC_MD5_DIGESTLENGTH];
	
	isc_md5_init( &context);
	isc_md5_update( &context, (const unsigned char *) [self bytes], (unsigned int)[self length]);
	isc_md5_final( &context, digest);
	
	NSString *str = [[NSData dataWithBytes:digest length:ISC_MD5_DIGESTLENGTH] description];
	NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@" ><"];
	str = [str stringByTrimmingCharactersInSet:charSet];
	
	int i;
	unsigned int len = (unsigned int)[str length];
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
@end
