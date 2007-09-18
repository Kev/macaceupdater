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
#import <AGRegex/AGRegex.h>

@implementation Plugin

- (Plugin*) initFromDictionary:(NSDictionary*)dictionary {

	self = [super init];
	if (self != nil) {
		name_ = [[dictionary objectForKey: @"title"] retain];
		description_ = [[dictionary objectForKey: @"description"] retain];
		installedVersion_ = @"";
		latestVersion_ = [[dictionary objectForKey: @"wowaddon:version"] retain];
		url_ = [[dictionary objectForKey: @"guid"] retain];
		NSLog(@"Adding URL");
		NSLog([dictionary objectForKey: @"guid"]);
		date_ = [[dictionary objectForKey: @"pubDate"] retain];
		selectedForInstall_ = false;
		
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
		changelog = [changelog lowercaseString];
		//NSLog(@"Looking at file:");
		//NSLog(changelog);
		if ( [changelog rangeOfString:@"macaceupdater-version-"].location != NSNotFound ) {
			NSLog(@"Found mau version:");
			NSLog(changelog);
			AGRegex *regex = [[AGRegex alloc] initWithPattern:@"macaceupdater-version-(.+)\.txt" options:AGRegexCaseInsensitive]; 
			AGRegexMatch *match = [regex findInString:changelog];
			if ([match count] == 2) { 
				version = [match groupAtIndex:1];
			} else {
				NSLog(@"ERROR: regex failure on mau version extraction");
			}
			NSLog(version);
			[regex release];
			break;
		}
		if ( [changelog rangeOfString:@"changelog-"].location != NSNotFound ) {
			NSLog(@"Found changelog:");
			NSLog(changelog);
			AGRegex *regex = [[AGRegex alloc] initWithPattern:@"changelog.*-r(.+)\.txt" options:AGRegexCaseInsensitive]; 
			AGRegexMatch *match = [regex findInString:changelog];
			if ([match count] == 2) { 
				version = [match groupAtIndex:1];
			} else {
				NSLog(@"ERROR: regex failure on changelog version extraction");
			}
			NSLog(version);
			[regex release];
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

- (NSString*) description
{
	//return @"myDesc";
	return description_;
}

- (NSString*) pluginDescription
{
	//return @"myDesc";
	return [self description];
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

- (id)valueForUndefinedKey:(NSString *)key
{
  if ([key isEqualToString:@"latest"])
  {
    return [self latestVersion];
  }
  else if ([key isEqualToString:@"installed"])
  {
    return [self installedVersion];
  }
  return nil;
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
    double latestDouble = [[self latestVersion] doubleValue];
    double installedDouble = [[self installedVersion] doubleValue];

		if (installedDouble >= latestDouble) {
      NSLog(@"%f %f", installedDouble, latestDouble);
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
	[scanner scanUpToString:[name_ stringByAppendingString:@"/"] intoString:nil];
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
	
	NSString* versionFile=nil;
	versionFile = [NSString stringWithString:[PluginManager addonDir]];
	versionFile = [versionFile stringByAppendingString:[self name]];
	versionFile = [versionFile stringByAppendingString:@"/macaceupdater-version-"];
	versionFile = [versionFile stringByAppendingString:latestVersion_];
	versionFile = [versionFile stringByAppendingString:@".txt"];
	
	[[NSData dataWithBytes:"empty" length:5] writeToFile:[versionFile
                 stringByExpandingTildeInPath]
                 atomically:YES];
	NSLog(@"Storing updated version in ");
	NSLog(versionFile);
	[self setSelectedForInstall:false];
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
