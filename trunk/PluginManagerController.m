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
	
	[self checkAddonsDirExists];
	[self statusUpdate:@"Ready"];
	
	
	
}

- (BOOL)checkAddonsDirExists
{
	NSFileManager *manager = [NSFileManager defaultManager];
	if (![manager fileExistsAtPath:[PluginManager addonDir]]) {
		[progressText setEditable:true];
		[progressText insertText:@"Addons dir not found; please go set the correct location in the Preferences\n"];
		[progressText setEditable:false];
		/*[prefsWindow makeKeyAndOrderFront:nil];
		[mainWindow orderBack:self];*/
		NSRunAlertPanel(@"Invalid Addons Dir", @"The AddOns directory cannot be found; please set the path in the application Preferences.", @"OK",nil,nil);
		[prefsWindow orderFront:self];
		return false;
	}
	return true;
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

- (IBAction)RescanPlugins:(id)sender
{
	if (![self checkAddonsDirExists]) {
		return;
	}
	[progressText setEditable:true];
	[progressText insertText:@"Scanning installed addons\n"];
	[progressText setEditable:false];
	
	[self statusUpdate:@"Scanning"];


	int i=0;
	PluginList *plugins = [pluginManager_ pluginList];
	while (i < [plugins count]) {
		[[plugins objectAtIndex:i] findInstalledVersion];
		i++;
	}
	[progressText setEditable:true];
	[progressText insertText:@"Local addons rescanned\n"];
	[progressText setEditable:false];
	[pluginList reloadData];
	[self statusUpdate:@"Ready"];
}

- (IBAction)InstallPlugins:(id)sender
{
	if (![self checkAddonsDirExists]) {
		return;
	}
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
			[[plugins objectAtIndex:i] findInstalledVersion];
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

- (IBAction)UninstallPlugins:(id)sender
{
	if (![self checkAddonsDirExists]) {
		return;
	}
	[progressText setEditable:true];
	[progressText insertText:@"Uninstalling Selected plugins\n"];
	[progressText setEditable:false];
	
	[self statusUpdate:@"Uninstalling"];
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
	int uninstalled=0;
	int attempted=0;
	
	PluginList *plugins = [pluginManager_ pluginList];
	while (i < [plugins count]) {
		if ([[plugins objectAtIndex:i] selectedForInstall]) {
			NSString* text=[[@"Uninstalling plugin: " stringByAppendingString:[[plugins objectAtIndex:i] name]] stringByAppendingString:@"\n"];
			[progressText setEditable:true];
			[progressText insertText:text];
			[progressText setEditable:false];
	
			[self statusUpdate:text];
			BOOL success = [[plugins objectAtIndex:i] uninstallWithBackupTo:backups];
			[[plugins objectAtIndex:i] findInstalledVersion];
			attempted++;
			if (success == YES) {
				text=@"Plugin Uninstallation: Complete\n";
				uninstalled++;
			} else {
				text=@"Plugin Uninstallation: Failed\n";
			}
			[progressText setEditable:true];
			[progressText insertText:text];
			[progressText setEditable:false];
		}
		i++;
	}
	[progressText setEditable:true];
	[progressText insertText:@"Plugins Uninstalled\n"];
	[progressText setEditable:false];
	[pluginList reloadData];
	[self statusUpdate:@"Ready"];
	[notifications_ announceMessageString:[NSString stringWithFormat:@"%@ %i %@ %i %@", @"Successfully uninstalled ", uninstalled, @" of ", attempted, @" addons."]];
}


- (IBAction)initialiseGUI:(id)sender
{
	[self doInit];
	
}

- (IBAction)selectOutdated:(id)sender
{
	if (![self checkAddonsDirExists]) {
		return;
	}
	[[pluginManager_ pluginList] selectOutdated];
	[searchItemView setStringValue:@""];
	[[pluginManager_ pluginList] searchPluginsForString:@""];
	[pluginList reloadData];
}

- (IBAction)selectAll:(id)sender
{
	[[pluginManager_ pluginList] selectAll];
	[searchItemView setStringValue:@""];
	[[pluginManager_ pluginList] searchPluginsForString:@""];
	[pluginList reloadData];
}

- (IBAction)selectNone:(id)sender
{
	[[pluginManager_ pluginList] selectNone];
	[searchItemView setStringValue:@""];
	[[pluginManager_ pluginList] searchPluginsForString:@""];
	[pluginList reloadData];
}

- (IBAction)selectInvert:(id)sender
{
	[[pluginManager_ pluginList] selectInvert];
	[searchItemView setStringValue:@""];
	[[pluginManager_ pluginList] searchPluginsForString:@""];
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
	if ([[PluginManager addonDir] isEqualToString:
					[preferencesAddOnsDir stringValue]] == NO) {
		[pluginManager_ setAddOnDirWithString:
								[preferencesAddOnsDir stringValue]];
		[self RescanPlugins:nil];
	}
}

- (IBAction)resetProperties:(id)sender
{
	[preferencesListURL setStringValue:[[pluginManager_ listURL] absoluteURL]];
	[preferencesAddOnsDir setStringValue:[PluginManager addonDir]];
}

- (IBAction)addonsBrowse:(id)sender
{
    int result;
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setCanChooseFiles:NO];
	[openPanel setCanChooseDirectories:YES];
	result = [openPanel runModalForDirectory:[preferencesAddOnsDir stringValue] file:nil types:nil];
    if (result != NSOKButton) {
		return;
	}
    NSArray *addonPath = [openPanel filenames];
	if ([addonPath count] < 1) {
		NSLog(@"ERROR: filesToOpen count < 1");
	}
	[preferencesAddOnsDir setStringValue:[addonPath objectAtIndex:0]];
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
		[item setImage:[NSImage imageNamed:@"InstallIcon"]];
		[item setTarget:self];
		[item setAction:@selector(InstallPlugins:)];
    } else if ( [itemIdentifier isEqualToString:@"UpdatePlugins"] ) {
		[item setLabel:@"Select Outdated Plugins"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"SelectIcon"]];
		[item setTarget:self];
		[item setAction:@selector(selectOutdated:)];
    }else if ( [itemIdentifier isEqualToString:@"UninstallPlugins"] ) {
		[item setLabel:@"Uninstall Selected Plugins"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"UnInstallIcon"]];
		[item setTarget:self];
		[item setAction:@selector(UninstallPlugins:)];
    } else if ( [itemIdentifier isEqualToString:@"Refresh"] ) {
		[item setLabel:@"Refresh List"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"RefreshIcon"]];
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
					 @"UninstallPlugins",
					 @"UpdatePlugins",
					 @"Refresh",
					 @"SearchPlugins",
					 nil];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
	return [NSArray arrayWithObjects:@"InstallPlugins",
									 @"UninstallPlugins",
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
