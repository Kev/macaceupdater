/*
 * Plugin.h - Header file for the Plugin entity class.
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
 
#import <Cocoa/Cocoa.h>

@interface Plugin : NSObject
{
	NSString* name_;
	NSString* description_;
	NSString* latestVersion_;
	NSString* installedVersion_;
	NSURL* url_;
	NSString* date_;
	Boolean selectedForInstall_;
}

- (Plugin*) initFromDictionary:(NSDictionary*)dictionary;
- (NSString*) name;
//these two methods are identical: the description is a duplicate to allow easier sorting
- (NSString*) description;
- (NSString*) pluginDescription;
- (NSString*) latestVersion;
- (NSString*) installedVersion;
- (BOOL) backupTo:(NSString*) backups;
- (BOOL) uninstallWithBackupTo:(NSString*) backups;
- (NSURL*) url;
- (NSString*) pluginDirName;
- (bool) selectedForInstall;
- (void) setSelectedForInstall:(bool) selected;
- (void) findInstalledVersion;
- (void) selectIfOutdated;
- (BOOL) installWithBackupTo:(NSString*) backups;
- (NSString*) downloadLatest;
/*- (void) setName:(NSString*) name;
- (void) setDescription:(NSString*) description;
- (void) setLatestVersion:(NSString*) version;
- (void) setUrl:(NSString*) url;
- (void) SetDateTime:(NSString*) date;*/
@end
