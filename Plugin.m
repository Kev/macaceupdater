/*
 * Plugin.m - Implementation file for the Plugin entity class.
 * Copyright (C) 2006  Kevin Smith.
 *
 * This file is part of the MacAceUpdater program.
 * 
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License,
 * as published by the Free Software Foundation, version 2.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 */

#import "Plugin.h"
#import "PluginManager.h"


@implementation Plugin

- (Plugin*) initFromString:(NSString*)string withBaseUrl:(NSURL*)baseUrl {
	if ( [string rangeOfString:@"<tr>"].location == NSNotFound ) {
		return nil;
	}

	self = [super init];
	if (self != nil) {
		name_ = @"";
		description_ = @"";
		installedVersion_ = @"";
		latestVersion_ = @"";
		url_ = @"";
		date_ = @"";
		selectedForInstall_ = false;
		
		NSScanner *scanner = [NSScanner scannerWithString:string];
	
		//while ( [scanner isAtEnd] == NO) {
		
			NSString *segment=nil;
			NSString *junk=nil;
			//NSLog(@"Line, Segments");
			//NSLog(string);
			if ([scanner isAtEnd] == YES) {
				return nil;
			}
			[scanner scanUpToString:@"<td>" intoString:&junk];
			[scanner scanString:@"<td>" intoString:&junk];
			if ([scanner isAtEnd] == YES) {
				return nil;
			}
			//NSLog(segment);
			[scanner scanUpToString:@"</td>" intoString:&segment];
			[scanner scanString:@"</td>" intoString:&junk];
			
			NSScanner *nameScanner = [NSScanner scannerWithString:segment];
			NSString *segment2=nil;
			[nameScanner scanString:@"<a href=\"" intoString:&segment2];
			[nameScanner scanUpToString:@"\">" intoString:&segment2];
			if ([segment2 hasPrefix:@"http://"]) {
				NSLog(@"Full URL");
				url_ = [[NSURL URLWithString:segment2] retain];
			} else {
				url_ = [[NSURL URLWithString:segment2 relativeToURL:baseUrl] retain];
			}
			NSLog(@"Creating URL from:");
			NSLog(segment2);
			
			[nameScanner scanString:@"\">" intoString:&segment2];
			[nameScanner scanUpToString:@"</a>" intoString:&segment2];
			
			name_ = [[NSString stringWithString:segment2] retain];
			[scanner scanUpToString:@"<td>" intoString:&segment];
			[scanner scanString:@"<td>" intoString:&junk];
			if ([scanner isAtEnd] == YES) {
				return nil;
			}
			
			//NSLog(name_);
			[scanner scanUpToString:@"</td>" intoString:&segment];
			[scanner scanString:@"</td>" intoString:&junk];
			latestVersion_ = [[NSString stringWithString:segment] retain];
			[scanner scanUpToString:@"<td" intoString:&junk];
			[scanner scanUpToString:@">" intoString:&junk];
			[scanner scanString:@">" intoString:&junk];
			if ([scanner isAtEnd] == YES) {
				return nil;
			}
			//NSLog(latestVersion_);
			[scanner scanUpToString:@"</td>" intoString:&segment];
			[scanner scanString:@"</td>" intoString:&junk];
			date_ = [[NSString stringWithString:segment] retain];
			[scanner scanUpToString:@"<td>" intoString:&segment];
			[scanner scanString:@"<td>" intoString:&junk];
			if ([scanner isAtEnd] == YES) {
				return nil;
			}
			//NSLog(date_);
			if ([scanner isAtEnd] == YES) {
				return nil;
			}
			[scanner scanUpToString:@"</td>" intoString:&segment];
			description_ = [[NSString stringWithString:segment] retain];
			//NSLog(description_);
			
			
		//}
		[self findInstalledVersion];
	}
	
	return self;
}

- (void) findInstalledVersion
{
	
	//NSLog([@"Finding version for: " stringByAppendingString:name_]);
	NSString* version=nil;
	NSString* dirName=nil;
	dirName = [NSString stringWithString:[PluginManager addonDir]];
	dirName = [dirName stringByAppendingString:[self name]];
	dirName = [dirName stringByAppendingString:@"/"];
	
	//NSLog(@"Looking in dir:");
	//NSLog(dirName);
	BOOL isDirectory=false;
	if (!([[NSFileManager defaultManager] fileExistsAtPath: dirName isDirectory:&isDirectory ] && isDirectory)) {
		//NSLog(@"Directory doesn't exist");
		installedVersion_ = @"";
		return;
	}
	NSArray *dirContents = [[NSFileManager defaultManager] directoryContentsAtPath:dirName];
	NSString *changelog = nil;
	version=@"";
	int i=0;
	while (i < [dirContents count]) {
		changelog = [dirContents objectAtIndex:i];
		//NSLog(@"Looking at file:");
		//NSLog(changelog);
		if ( [changelog rangeOfString:@"changelog-"].location != NSNotFound ) {
			//NSLog(@"Found changelog:");
			//NSLog(changelog);
			version = [changelog substringWithRange:NSMakeRange(10,6)];
			//NSLog(version);
		}
		i++;
	}
	
	installedVersion_ = [[NSString stringWithString:version] retain];
}

- (NSString*) name
{
	//return @"myName";
	return name_;
}

- (NSURL*) url
{
	return url_;
}

- (NSString*) pluginDescription
{
	//return @"myDesc";
	return description_;
}

- (NSString*) latestVersion
{
	//return @"latestV";
	return latestVersion_;
}

- (NSString*) installedVersion
{
	return installedVersion_;
}

- (bool) selectedForInstall
{
	//return @"YES";
	return selectedForInstall_;
}

- (void) setSelectedForInstall:(bool) selected
{
	selectedForInstall_ = selected;
}

- (void) selectIfOutdated
{
	if ([installedVersion_ isEqualToString:@""]) {
		//no version is installed, so no reason to upgrade
	} else {
		if ([[self installedVersion] isEqualToString:latestVersion_]) {
			//We already have the latest version
		} else {
			[self setSelectedForInstall:true];
		}
	}
	//FIXME: This seems to not work :(
}

- (NSString*) pluginDirName
{
	NSString* pluginDirName = [NSString stringWithString:[PluginManager addonDir]];
	pluginDirName = [pluginDirName stringByAppendingString:[self name]];
	pluginDirName = [pluginDirName stringByAppendingString:@"/"];
	return [pluginDirName autorelease];
}

- (BOOL) backupTo:(NSString*) backups
{
	if (![installedVersion_ isEqualToString:@""]) {
		if ([[NSFileManager defaultManager] movePath:[self pluginDirName] toPath:[backups stringByAppendingString:name_] handler:nil] == NO) {
			NSLog(@"Error backing up old plugin");
			return NO;
		}
	}
	return YES;
}

- (NSString*) downloadLatest
{
	//make AddOns/_downloadedfiles if it doesn't exist
	NSString* downloads = [[PluginManager addonDir] stringByAppendingString:@"_downloads/"];
	NSLog([@"Downloading to folder: " stringByAppendingString:downloads ]);
	BOOL isDirectory;
	if (![[NSFileManager defaultManager] fileExistsAtPath: downloads isDirectory:&isDirectory ]) {
		NSLog(@"Download directory doesn't exist, creating");
		[[NSFileManager defaultManager] createDirectoryAtPath: downloads attributes: nil];
	}
	if (!([[NSFileManager defaultManager] fileExistsAtPath: downloads isDirectory:&isDirectory ] && isDirectory)) {
		NSLog(@"ERROR: Directory doesn't exist, or is a file");
		return NO;
	}
	
	//Download - If Zip already exists, delete and start again
	NSScanner *scanner = [NSScanner scannerWithString:[url_ relativePath]];
	NSString *bareFileName=nil;
	[scanner scanString:[name_ stringByAppendingString:@"/"] intoString:nil];
	[scanner scanUpToString:@"" intoString:&bareFileName];
	NSString* zipFileName = [[downloads stringByAppendingString:bareFileName] retain];
	NSLog([@"Downloading file " stringByAppendingString:[url_ absoluteString]]);
	NSLog([@"To " stringByAppendingString:zipFileName]);
	if ([UrlGrabber getPage:url_ toFile:zipFileName] == YES) {
		return [zipFileName autorelease];
	}
	return @"";
}

//pass nil to not backup
- (BOOL) installWithBackupTo:(NSString*) backups
{
	NSLog([@"Trying to install plugin: " stringByAppendingString:name_ ]);
	//The order is important here so as not to lose AddOns if the download fails.
	//First download it, and abort if it fails
	NSString* downloadedArchive=[[self downloadLatest] retain];
	if ([downloadedArchive isEqualToString:@""]) {
		return NO;
	}
	//only Make a backup if backups != nil
	if (backups != nil) {
		if ([self backupTo:backups] == NO)
		{
			NSLog(@"Backup failed, aborting install");
			return NO;
		}
	} else {
		[self uninstallWithBackupTo:nil];
	}

	
	//Unzip new one
	NSTask *unzipTask = [[NSTask alloc] init];
	/*
	//Note: I found the following snippet online which might work better
	 [cmnd setLaunchPath:@"/usr/bin/ditto"];
	[cmnd setArguments:[NSArray arrayWithObjects:
	@"-v",@"-x",@"-k",@"--rsrc",sourcePath,targetPath,nil]]; */
	[unzipTask setLaunchPath:@"/usr/bin/unzip"];
	[unzipTask setArguments:
	[NSArray arrayWithObjects: @"-o", downloadedArchive, @"-d",[PluginManager addonDir], nil]];
	NSLog(@"Trying to Unzip from: To:");
	NSLog(downloadedArchive);
	NSLog([PluginManager addonDir]);
	
	//NSLog([@"Unzipping with command: " stringByAppendingString:[unzipTask ]]);	
	[unzipTask launch];
	[unzipTask waitUntilExit];
		
	if ([unzipTask terminationStatus] != 0) {
		NSLog(@"Unzip failed.");
		return NO;
	}
	[unzipTask release];
	[downloadedArchive release];
	
	return YES;
}

- (BOOL) uninstallWithBackupTo:(NSString*) backups
{
	if (backups == nil) {
		return [[NSFileManager defaultManager] removeFileAtPath:[self pluginDirName] 
						handler:nil];
	}
	return [self backupTo:backups];
}

@end
