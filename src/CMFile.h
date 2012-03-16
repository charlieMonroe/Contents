//
//  CMFile.h
//  LibraryLiberty
//
//  Created by alto on 8/23/09.
//  Copyright 2009 FuelCollective. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CMFile : NSObject {

}

+(BOOL)isBundleAtPath:(NSString*)path;
+(BOOL)isDirectory:(NSString*)path;

+(NSString*)resolvedAlias:(NSString*)path;

+(unsigned long long)sizeOfFileIncludingResourceFork:(NSString*)path;
+(unsigned long long)sizeOfFolder:(NSString*)path;

/********* Deleting *******/
+(BOOL)removeFile:(NSString*)path;

/********* Moving *******/
+(BOOL)moveFile:(NSString*)path toFolder:(NSString*)dest;

+(BOOL)_moveFileWithoutAuthentication:(NSString*)path toPath:(NSString*)destination;
+(BOOL)_moveFileWithAuthentication:(NSString*)path toPath:(NSString*)destination;

/********* Copying *******/
+(BOOL)copyFile:(NSString*)path toFolder:(NSString*)dest;
+(BOOL)copyFileReplacingOldOne:(NSString*)path toFolder:(NSString*)dest;

+(BOOL)_copyFileWithoutAuthentication:(NSString*)path toPath:(NSString*)destination;
+(BOOL)_copyFileWithAuthentication:(NSString*)path toPath:(NSString*)destination;

@end
