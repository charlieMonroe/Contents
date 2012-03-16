//
//  CMFileSizeTransformer.m
//  LibraryLiberty
//
//  Created by Krystof Vasa on 8/23/09.
//  Copyright 2009 FuelCollective, LLC. All rights reserved.
//

#import "CMFileSizeTransformer.h"


@implementation CMFileSizeTransformer

-(id)transformedValue:(id)value{
	NSNumber *num = value;
	float size = [num floatValue];
	if (num == nil){
		return @"-- kB";
	}else if (size<1024){
		return [NSString stringWithFormat:@"%0.00f B" ,size];
	}else if (size<(1024 * 1024)){
		return [NSString stringWithFormat:@"%0.00f kB",size/1024];
	}else if (size<(1024 * 1024 * 1024)){
		return [NSString stringWithFormat:@"%0.2f MB",(size/1024)/1024];
	}else{ // if (size<(1024 * 1024 * 1024 * 1024))
		return [NSString stringWithFormat:@"%0.2f GB",((size/1024)/1024)/1024];
	}
	return @"-- kB";
}

@end
