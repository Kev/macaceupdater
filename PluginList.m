/*
 * PluginList.m - Implementation file for the Plugin container class.
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

#import "PluginList.h"

@implementation PluginList

- (PluginList*) init
{
	[super init];
	plugins_ = [[NSMutableArray alloc] initWithCapacity:500];
	return self;
}

- (id)tableView:(NSTableView *)aTableView 
    objectValueForTableColumn:(NSTableColumn *)aTableColumn
    row:(int)rowIndex
{
	//NSLog(@"Asking for a value");
    Plugin* plugin;
	id theValue;
 
    NSParameterAssert(rowIndex >= 0 && rowIndex < [plugins_ count]);
	//NSLog([NSString stringWithFormat: @"Getting Row %i / %i", rowIndex, [plugins_ count]]);
	
	
    plugin = [plugins_ objectAtIndex:rowIndex];
	if ( plugin == nil ) {
		NSLog(@"Emergency - a nil plugin is in the list");
	}
	NSString* column = (NSString*)[aTableColumn identifier];
	//NSLog(column);
	if ([column isEqualToString:@"installed"])
	{
		//NSLog(@"Found a request for installed");
		theValue = [plugin installedVersion];
	} else if ([column isEqualToString:@"latest"])
	{
		//NSLog(@"Found a request for latest");
		theValue = [plugin latestVersion];
		//NSLog(@"meh");
	} else if ([column isEqualToString:@"name"])
	{
		//NSLog(@"Found a request for name");
		theValue = [plugin name];
	} else if ([column isEqualToString:@"description"])
	{
		//NSLog(@"Found a request for desc");
		theValue = [plugin pluginDescription];
	} else if ([column isEqualToString:@"install"])
	{
		//NSLog(@"Found a request for install");
		if ([plugin selectedForInstall]) {
			theValue = [NSNumber numberWithInt:NSOnState];
		} else {
			theValue = [NSNumber numberWithInt:NSOffState];
		}
	} else {
		NSLog(@"Asking for illegal column:");
		NSLog(column);
		theValue = nil;
	}
	//NSLog(@"semiboom");
	if (theValue == nil) {
		NSLog(@"Emergency - nil theValue");
	}
	//NSLog(@"semiboomboom");
	/*if ([[theValue class] isEqualTo:[NSString class]])
	{
		NSLog(@"boom");
		NSLog(theValue);
	} else {
		NSLog(@"Not a String");
		//NSLog([theValue class]);
	}*/
	//NSLog(@"boomboom");
	
	//NSLog((NSString*)theValue);
    return theValue;
}

- (void)tableView:(NSTableView *)aTableView
    setObjectValue:anObject
    forTableColumn:(NSTableColumn *)aTableColumn
    row:(int)rowIndex
{
    Plugin* plugin;
 
    NSParameterAssert(rowIndex >= 0 && rowIndex < [plugins_ count]);
	NSParameterAssert([[aTableColumn identifier] isEqualToString: @"install" ]);
    plugin = [plugins_ objectAtIndex:rowIndex];
	
	bool enable = ([[NSNumber numberWithInt:NSOnState] isEqualTo:anObject]);
	
    [plugin setSelectedForInstall:enable];
    return;
}

- (int)numberOfRowsInTableView:(NSTableView *)aTable
{
    return [plugins_ count];
}

- (void)loadFromUrl:(NSURL*) url
{

	//get the plugin list file into memory
	NSString *page = [[UrlGrabber getPageAsString:url] retain];
	NSScanner *scanner = [NSScanner scannerWithString:page];
	
	while ( [scanner isAtEnd] == NO) {
		NSString* line;
		[scanner scanUpToString:@"\n" intoString:&line];
		//NSLog(@"Line:");
		//NSLog(line);
		Plugin* plugin = [[Plugin alloc] initFromString:line withBaseUrl:url];
		
		NSLog(line);
		if ( plugin != nil) {
			NSLog(@"Adding line");
			NSLog([plugin name]);
			[plugins_ addObject: [plugin retain]];
		} else {
			NSLog(@"Nil pointer from line:");
		}
	}
	NSLog(@"Added this many plugins:");
	NSLog([NSString stringWithFormat:@"%d", [plugins_ count]]);
}

- (void) selectOutdated
{
	int i=0;
	while (i < [plugins_ count]) {
		[[plugins_ objectAtIndex:i] selectIfOutdated];
		i++;
	}
	//FIXME: now signal that a redraw is in order.
}

- (Plugin*) objectAtIndex: (int) index
{
	return [plugins_ objectAtIndex:index];
}

- (int) count
{
	return [plugins_ count];
}

@end
