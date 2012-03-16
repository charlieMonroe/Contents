//
//  CMFile.m
//  LibraryLiberty
//
//  Created by alto on 8/23/09.
//  Copyright 2009 FuelCollective. All rights reserved.
//

#import "CMFile.h"
#import <sys/stat.h>


@implementation CMFile
+(BOOL)isBundleAtPath:(NSString*)path{
	NSFileManager *fileMan = [NSFileManager defaultManager];
	NSString *pkgInfo = [[path stringByAppendingPathComponent:@"Contents"] stringByAppendingPathComponent:@"PkgInfo"];
	NSString *infoPlist = [[path stringByAppendingPathComponent:@"Contents"] stringByAppendingPathComponent:@"Info.plist"];
	if ([fileMan fileExistsAtPath:pkgInfo] || [fileMan fileExistsAtPath:infoPlist] || ([CMFile isDirectory:path] && [[path pathExtension] isEqualToString:@"app"])){
		return YES;
	}
	return NO;
}
+(BOOL)isDirectory:(NSString*)path{
	struct stat file_status;
	stat([path fileSystemRepresentation], &file_status);
	return S_ISDIR(file_status.st_mode);
}

+(NSString*)resolvedAlias:(NSString*)path{
	NSString *resolvedPath = nil;
	CFURLRef url = CFURLCreateWithFileSystemPath
	(kCFAllocatorDefault, (CFStringRef)path, kCFURLPOSIXPathStyle, NO);
	if (url != NULL){
		FSRef fsRef;
		if (CFURLGetFSRef(url, &fsRef)){
			Boolean targetIsFolder, wasAliased;
			FSResolveAliasFile (&fsRef, true, &targetIsFolder, &wasAliased);
			CFURLRef resolvedUrl = CFURLCreateFromFSRef(kCFAllocatorDefault, &fsRef);
			if (resolvedUrl != NULL){
				resolvedPath = (NSString*)CFURLCopyFileSystemPath(resolvedUrl, kCFURLPOSIXPathStyle);
				CFRelease(resolvedUrl);
			}
		}
		CFRelease(url);
	}
	
	if (resolvedPath == nil){
		resolvedPath = [[NSString alloc] initWithString:path];
	}
	return [resolvedPath autorelease];
}

+(unsigned long long)sizeOfFileIncludingResourceFork:(NSString *)path{
	FSRef theFileRef;
	OSErr err = FSPathMakeRef((UInt8*)[path fileSystemRepresentation], &theFileRef, NULL);
	
	if (err != noErr){
		return 0;
	}
	
	FSCatalogInfo info;
	err = FSGetCatalogInfo(&theFileRef, kFSCatInfoDataSizes | kFSCatInfoNodeFlags, &info, NULL, NULL, NULL);
	if (err == noErr){
		unsigned long long size = 0;
		size = info.dataLogicalSize + info.rsrcLogicalSize;
		return size;
	}
	
	return 0;
}
+(unsigned long long)sizeOfFolder:(NSString*)path{
	NSPipe *pipe = [NSPipe pipe];
	NSTask *t = [[NSTask new] autorelease];
	[t setLaunchPath:@"/usr/bin/du"];
	[t setArguments:[NSArray arrayWithObjects:@"-k", @"-d", @"0", path, nil]];
	[t setStandardOutput:pipe];
	[t setStandardError:[NSPipe pipe]];
	
	[t launch];
	
	[t waitUntilExit];
	
	NSString *size = [[[NSString alloc] initWithData:[[pipe fileHandleForReading] availableData] encoding:NSASCIIStringEncoding] autorelease];
	size = [[size componentsSeparatedByString:@" "] objectAtIndex:0];
	
	return (unsigned long long)[size doubleValue]*1024;
}

+(BOOL)moveFile:(NSString*)path toFolder:(NSString*)dest{
	NSString *destination = [dest stringByAppendingPathComponent:[path lastPathComponent]];
	if ([[NSFileManager defaultManager] fileExistsAtPath:destination]){
		NSString *tmpDest = destination;
		int i = 0;
		while ([[NSFileManager defaultManager] fileExistsAtPath:tmpDest]){
			++i;
			tmpDest = [dest stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%i%@%@", [[path lastPathComponent] stringByDeletingPathExtension], i, [[path pathExtension] isEqualToString:@""]?@"":@".", [path pathExtension]]];
		}
		destination = tmpDest;
	}
	if (![CMFile _moveFileWithoutAuthentication:path toPath:destination]){
		return [CMFile _moveFileWithAuthentication:path toPath:destination];
	}
	return YES;
}
+(BOOL)_moveFileWithoutAuthentication:(NSString*)path toPath:(NSString*)destination{
	NSTask *hdiTask = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/env" arguments:[NSArray arrayWithObjects:@"mv", path, destination, nil]];
	[hdiTask waitUntilExit];
	return [hdiTask terminationStatus]==0;
}
+(BOOL)_moveFileWithAuthentication:(NSString*)path toPath:(NSString*)destination{
	BOOL res = NO;
	struct stat sb;
	
	if ((stat([path UTF8String], &sb) != 0) && (stat([destination UTF8String], &sb) != 0))
		return NO;
	
	char* buf = NULL;
	asprintf(&buf, "mv \"$SRC_PATH\" \"$DST_PATH\"");
	
	if(!buf) return NO;
	
	AuthorizationRef auth;
	if(AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &auth) == errAuthorizationSuccess){
		setenv("SRC_PATH", [path UTF8String], 1);
		setenv("DST_PATH", [destination UTF8String], 1);
		
		sig_t oldSigChildHandler = signal(SIGCHLD, SIG_DFL);
		char const* arguments[] = { "-c", buf, NULL };
		if(AuthorizationExecuteWithPrivileges(auth, "/bin/sh", kAuthorizationFlagDefaults, (char**)arguments, NULL) == errAuthorizationSuccess){
			int status;
			int pid = wait(&status);
			if(pid != -1 && WIFEXITED(status) && WEXITSTATUS(status) == 0)
				res = YES;
		}
		signal(SIGCHLD, oldSigChildHandler);
	}
	AuthorizationFree(auth, 0);
	free(buf);
	if (res==NO){
		return NO;
	}
	return [[NSFileManager defaultManager] fileExistsAtPath:destination];
}

+(BOOL)copyFileReplacingOldOne:(NSString*)path toFolder:(NSString*)dest{
	NSString *destination = [dest stringByAppendingPathComponent:[path lastPathComponent]];
	if (![[NSFileManager defaultManager] fileExistsAtPath:destination]){
		return [CMFile copyFile:path toFolder:dest];
	}
	
	destination = [dest stringByAppendingPathComponent:[NSString stringWithFormat:@".__%@%@%@", [[path lastPathComponent] stringByDeletingPathExtension], [[path pathExtension] isEqualToString:@""]?@"":@".", [path pathExtension]]];
	
	BOOL result = [CMFile _copyFileWithoutAuthentication:path toPath:destination];
	if (!result){
		result = [CMFile _copyFileWithAuthentication:path toPath:destination];
	}
	if (!result){
		return NO;
	}
	
	[self removeFile:[dest stringByAppendingPathComponent:[path lastPathComponent]]];
	
	result = [CMFile _moveFileWithoutAuthentication:destination toPath:[dest stringByAppendingPathComponent:[path lastPathComponent]]];
	if (!result){
		result = [CMFile _copyFileWithAuthentication:destination toPath:[dest stringByAppendingPathComponent:[path lastPathComponent]]];
	}
	if (!result){
		return NO;
	}
	
	return YES;
}
+(BOOL)copyFile:(NSString*)path toFolder:(NSString*)dest{
	NSString *destination = [dest stringByAppendingPathComponent:[path lastPathComponent]];
	if ([[NSFileManager defaultManager] fileExistsAtPath:destination]){
		NSString *tmpDest = destination;
		int i = 0;
		while ([[NSFileManager defaultManager] fileExistsAtPath:tmpDest]){
			++i;
			tmpDest = [dest stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%i%@%@", [[path lastPathComponent] stringByDeletingPathExtension], i, [[path pathExtension] isEqualToString:@""]?@"":@".", [path pathExtension]]];
		}
		destination = tmpDest;
	}
	if (![CMFile _copyFileWithoutAuthentication:path toPath:destination]){
		return [CMFile _copyFileWithAuthentication:path toPath:destination];
	}
	return YES;
}
+(BOOL)_copyFileWithoutAuthentication:(NSString*)path toPath:(NSString*)destination{
	NSTask *hdiTask = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/env" arguments:[NSArray arrayWithObjects:@"cp", @"-R", path, destination, nil]];
	[hdiTask waitUntilExit];
	return [hdiTask terminationStatus]==0;
}
+(BOOL)_copyFileWithAuthentication:(NSString*)path toPath:(NSString*)destination{
	BOOL res = NO;
	struct stat sb;
	
	if ((stat([path UTF8String], &sb) != 0) && (stat([destination UTF8String], &sb) != 0))
		return NO;
	
	char* buf = NULL;
	asprintf(&buf, "cp -R \"$SRC_PATH\" \"$DST_PATH\"");
	
	if(!buf) return NO;
	
	AuthorizationRef auth;
	if(AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &auth) == errAuthorizationSuccess){
		setenv("SRC_PATH", [path UTF8String], 1);
		setenv("DST_PATH", [destination UTF8String], 1);
		
		sig_t oldSigChildHandler = signal(SIGCHLD, SIG_DFL);
		char const* arguments[] = { "-c", buf, NULL };
		if(AuthorizationExecuteWithPrivileges(auth, "/bin/sh", kAuthorizationFlagDefaults, (char**)arguments, NULL) == errAuthorizationSuccess){
			int status;
			int pid = wait(&status);
			if(pid != -1 && WIFEXITED(status) && WEXITSTATUS(status) == 0)
				res = YES;
		}
		signal(SIGCHLD, oldSigChildHandler);
	}
	AuthorizationFree(auth, 0);
	free(buf);
	if (res==NO){
		return NO;
	}
	return [[NSFileManager defaultManager] fileExistsAtPath:destination];
}

+(BOOL)removeFile:(NSString*)path{
	NSTask *hdiTask = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/env" arguments:[NSArray arrayWithObjects:@"rm", @"-rf", path, nil]];
	[hdiTask waitUntilExit];
	if ([hdiTask terminationStatus]==0){
		return YES;
	}
	
	//Authenticate
	BOOL res = NO;
	struct stat sb;
	
	if (stat([path UTF8String], &sb) != 0)
		return NO;
	
	char* buf = NULL;
	asprintf(&buf, "rm -rf \"$SRC_PATH\"");
	
	if(!buf) return NO;
	
	AuthorizationRef auth;
	if(AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &auth) == errAuthorizationSuccess){
		setenv("SRC_PATH", [path UTF8String], 1);
		
		sig_t oldSigChildHandler = signal(SIGCHLD, SIG_DFL);
		char const* arguments[] = { "-c", buf, NULL };
		if(AuthorizationExecuteWithPrivileges(auth, "/bin/sh", kAuthorizationFlagDefaults, (char**)arguments, NULL) == errAuthorizationSuccess){
			int status;
			int pid = wait(&status);
			if(pid != -1 && WIFEXITED(status) && WEXITSTATUS(status) == 0)
				res = YES;
		}
		signal(SIGCHLD, oldSigChildHandler);
	}
	AuthorizationFree(auth, 0);
	free(buf);
	if (res==NO){
		return NO;
	}
	return ![[NSFileManager defaultManager] fileExistsAtPath:path];
}

@end
