/*
 * PluginManager.m - Implementation file for central plugin controls.
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

#import "PluginManager.h"

@implementation PluginManager

- (PluginManager*) init
{
	
	
	[super init];
	[self ensurePreferencesExist];
	pluginList_ = [[PluginList alloc] init];
	[pluginList_ loadFromUrl:[self listURL]];
	return self;
}

/*- (bool) installPlugin: (NSString*) plugin 
{
	return false;
}*/

- (NSURL*) listURL;
{
	return [NSURL URLWithString: [[NSUserDefaults standardUserDefaults] objectForKey:@"AddOnsListFeedURL"]];

}

- (PluginList*) pluginList
{
	
	return pluginList_;
}

+ (NSString*) addonDir
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:@"AddOnsDirectory"];

}

- (void) setAddOnDirWithString:(NSString*) dir
{
	if ([dir length] == 0) {
		NSLog(@"Trying to set addondir to 0 length string");
		return;
	}
	if (![[dir substringFromIndex:[dir length] - 1] isEqualTo:@"/"]) {
		NSLog(@"Unable to find trailing / on directory, adding");
		NSLog(dir);
		dir = [dir stringByAppendingString:@"/"];
	}
	NSLog(@"Setting addon dir to");
	NSLog(dir);
	[[NSUserDefaults standardUserDefaults] setObject:dir
											   forKey:@"AddOnsDirectory"];
}

- (void) setListURLWithString:(NSString*) URL
{
	[[NSUserDefaults standardUserDefaults] setObject:URL
											   forKey:@"AddOnsListFeedURL"];
}

	
	

- (void) ensurePreferencesExist
{
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"AddOnsDirectory"] == nil) {
		[[NSUserDefaults standardUserDefaults] setObject:@"/Applications/World of Warcraft/Interface/AddOns/" 
											   forKey:@"AddOnsDirectory"];
	}
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"AddOnsListFeedURL"] == nil) {
		   [[NSUserDefaults standardUserDefaults] setObject:@"http://www.wowace.com/files/latest.xml" 
											   forKey:@"AddOnsListFeedURL"];
	}
}

@end
