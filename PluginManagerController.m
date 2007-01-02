/*
 * PluginManagerController.m - Implementation file for the application controller.
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

#import "PluginManagerController.h"

@implementation PluginManagerController

- (PluginManagerController*) init
{
	[super init];
	//[self doInit];
	notifications_ = [[Notifications alloc] init];
	return self;
}

- (void) awakeFromNib
{
	//FIXME: add a delay here so that the window appears before the lag.
	[self setupToolbar];
	[self doInit];
}

- (void) doInit
{
	[progressText setEditable:true];
	[self statusUpdate:@"Initialising"];
	[progressText insertText:@"Initialising MacAceUpdater\n"];
	[progressText setEditable:false];
	pluginManager_ = [[PluginManager alloc] init];
	
	[pluginList setDataSource:[pluginManager_ pluginList]];
	
	
	[self markedUpdate];
	
	[progressText setEditable:true];
	[progressText insertText:@"Initialised MacAceUpdater\n"];
	[progressText setEditable:false];
	
	[self resetProperties:nil];
	
	[self statusUpdate:@"Ready"];
	
	
	
}

- (void)markedUpdate
{

	int marked, total;
	marked=0;
	
	total=[[pluginManager_ pluginList] numberOfRowsInTableView:pluginList];
	
	[markedCount setStringValue:[NSString stringWithFormat:@"Marked: %d/%d", marked,total]];

}

- (void)statusUpdate:(NSString*)status
{
	[statusText setStringValue:status];
}

- (IBAction)InstallPlugins:(id)sender
{
	[progressText setEditable:true];
	[progressText insertText:@"Installing Selected plugins\n"];
	[progressText setEditable:false];
	
	[self statusUpdate:@"Installing"];
	NSString* backups = [[PluginManager addonDir] stringByAppendingString:@"_addonBackups/"];
	BOOL isDirectory;
	if (![[NSFileManager defaultManager] fileExistsAtPath: backups isDirectory:&isDirectory ]) {
		NSLog(@"Backup directory doesn't exist, creating");
		NSLog(backups);
		[[NSFileManager defaultManager] createDirectoryAtPath: backups attributes: nil];
	}
	if (!([[NSFileManager defaultManager] fileExistsAtPath: backups isDirectory:&isDirectory ] && isDirectory)) {
		NSLog(@"ERROR: Backup directory doesn't exist, or is a file");
		return ;
	}
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] initWithDateFormat:@"%Y-%m-%d_%H.%M.%S" allowNaturalLanguage:NO]  autorelease];
	backups = [backups stringByAppendingString:[dateFormatter stringFromDate:[NSDate date]]];
	backups = [backups stringByAppendingString:@"/"];
	if (![[NSFileManager defaultManager] fileExistsAtPath: backups isDirectory:&isDirectory ]) {
		NSLog(@"Backup directory doesn't exist, creating");
		NSLog(backups);
		[[NSFileManager defaultManager] createDirectoryAtPath: backups attributes: nil];
	}
	if (!([[NSFileManager defaultManager] fileExistsAtPath: backups isDirectory:&isDirectory ] && isDirectory)) {
		NSLog(@"ERROR: Backup directory doesn't exist, or is a file");
		return ;
	}
	
	int i=0;
	int installed=0;
	int attempted=0;
	
	PluginList *plugins = [pluginManager_ pluginList];
	while (i < [plugins count]) {
		if ([[plugins objectAtIndex:i] selectedForInstall]) {
			NSString* text=[[@"Installing plugin: " stringByAppendingString:[[plugins objectAtIndex:i] name]] stringByAppendingString:@"\n"];
			[progressText setEditable:true];
			[progressText insertText:text];
			[progressText setEditable:false];
	
			[self statusUpdate:text];
			BOOL success = [[plugins objectAtIndex:i] installWithBackupTo:backups];
			attempted++;
			if (success == YES) {
				text=@"Plugin Installation: Complete\n";
				installed++;
			} else {
				text=@"Plugin Installation: Failed\n";
			}
			[progressText setEditable:true];
			[progressText insertText:text];
			[progressText setEditable:false];
		}
		i++;
	}
	[progressText setEditable:true];
	[progressText insertText:@"Plugins Installed\n"];
	[progressText setEditable:false];
	[pluginList reloadData];
	[self statusUpdate:@"Ready"];
	[notifications_ announceMessageString:[NSString stringWithFormat:@"%@ %i %@ %i %@", @"Successfully installed ", installed, @" of ", attempted, @" addons."]];
}

- (IBAction)initialiseGUI:(id)sender
{
	[self doInit];
	
}

- (IBAction)selectOutdated:(id)sender
{
	[[pluginManager_ pluginList] selectOutdated];
	[pluginList reloadData];
}

- (void)setupToolbar
{
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"mainToolbar"];
    [toolbar setDelegate:self];
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setAutosavesConfiguration:YES];
	[mainWindow setToolbar:[toolbar autorelease]];
}

- (void)controlTextDidChange:(NSNotification *)notification
{
	//NSLog(@"CHANGED!");
	NSString* search = [[[notification object] stringValue] lowercaseString];
    [[pluginManager_ pluginList] searchPluginsForString:search];
    [pluginList reloadData];
}

- (IBAction)applyProperties:(id)sender
{
	NSLog(@"Applying");
	[pluginManager_ setListURLWithString:[preferencesListURL stringValue]];
	[pluginManager_ setAddOnDirWithString:[preferencesAddOnsDir stringValue]];
}

- (IBAction)resetProperties:(id)sender
{
	[preferencesListURL setStringValue:[[pluginManager_ listURL] absoluteURL]];
	[preferencesAddOnsDir setStringValue:[PluginManager addonDir]];
}

@end

@implementation PluginManagerController (ToolbarDelegateCategory)

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar
    itemForItemIdentifier:(NSString *)itemIdentifier
    willBeInsertedIntoToolbar:(BOOL)flag
{
	NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
	if ( [itemIdentifier isEqualToString:@"InstallPlugins"] ) {
		[item setLabel:@"Install Selected Plugins"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"Add"]];
		[item setTarget:self];
		[item setAction:@selector(InstallPlugins:)];
    } else if ( [itemIdentifier isEqualToString:@"UpdatePlugins"] ) {
		[item setLabel:@"Select Outdated Plugins"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"Add"]];
		[item setTarget:self];
		[item setAction:@selector(selectOutdated:)];
    } else if ( [itemIdentifier isEqualToString:@"Refresh"] ) {
		[item setLabel:@"Refresh List"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"Add"]];
		[item setTarget:self];
		[item setAction:@selector(doInit)];
    } else if ( [itemIdentifier isEqualToString:@"SearchPlugins"] ) {
		NSRect fRect = [searchItemView frame];
		[item setLabel:@"Search Plugins"];
		[item setPaletteLabel:[item label]];
		[item setView:searchItemView];
		[item setMinSize:fRect.size];
		[item setMaxSize:fRect.size];
    }
    return [item autorelease];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar
{
	return [NSArray arrayWithObjects:NSToolbarSeparatorItemIdentifier,
				     NSToolbarSpaceItemIdentifier,
				     NSToolbarFlexibleSpaceItemIdentifier,
				     NSToolbarCustomizeToolbarItemIdentifier, 
					 @"InstallPlugins",
					 @"UpdatePlugins",
					 @"Refresh",
					 @"SearchPlugins",
					 nil];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
	return [NSArray arrayWithObjects:@"InstallPlugins",
									 @"UpdatePlugins",
								     @"Refresh",
									 NSToolbarSpaceItemIdentifier,
									 NSToolbarCustomizeToolbarItemIdentifier,
									 NSToolbarFlexibleSpaceItemIdentifier,
									 @"SearchPlugins",
									 nil];
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem
{
    return YES;
}

@end