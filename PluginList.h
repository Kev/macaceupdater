/*
 * PluginList.h - Header file for the Plugin container class.
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
#import "Plugin.h"
#import "UrlGrabber.h"

@interface PluginList : NSObject
{
	NSMutableArray* plugins_;
	NSMutableArray* activeSet_;
	NSMutableArray* subSet_;
	
    NSTableColumn* sortedColumn_;  // track last column chosen
    SEL columnSortSelector_;      // holds a method pointer
    BOOL sortDescending_;         // sort in descending order
}

- (id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)aTableColumn
    row:(int)rowIndex;

- (void)tableView:(NSTableView *)aTableView
    setObjectValue:anObject
    forTableColumn:(NSTableColumn *)aTableColumn
    row:(int)rowIndex;


- (void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray *)oldDescriptors;	


- (int)numberOfRowsInTableView:(NSTableView *)aTableView;

- (void)loadFromUrl:(NSURL*) url;

- (void)selectOutdated;
- (Plugin*) objectAtIndex: (int) index;
- (int) count;
- (void) searchPluginsForString: (NSString*) searchString;
@end
