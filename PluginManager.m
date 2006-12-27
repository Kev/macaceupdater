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
	listUrl_ = [NSURL URLWithString:@"http://grid.13th-floor.org/wowace/"];
	pluginList_ = [[PluginList alloc] init];
	[pluginList_ loadFromUrl:listUrl_];
	return self;
}

/*- (bool) installPlugin: (NSString*) plugin 
{
	return false;
}*/

- (PluginList*) pluginList
{

	return pluginList_;
}

+ (NSString*) addonDir
{
	NSString* dir = [[NSUserDefaults standardUserDefaults] objectForKey:@"AddOnsDirectory"];
	if (dir == nil) {
		dir = @"/Applications/Games/World of Warcraft/Interface/AddOns/";
		[[NSUserDefaults standardUserDefaults] setObject:dir forKey:@"AddOnsDirectory"];
	}
	return dir;
}

@end
