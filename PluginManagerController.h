/*
 * PluginManagerController.h - Header file for the application controller.
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
#import "PluginManager.h"
#import "Notifications.h"

@interface PluginManagerController : NSObject
{
    IBOutlet NSTextField *markedCount;
    IBOutlet NSTableView *pluginList;
    IBOutlet NSTextView *progressText;
    IBOutlet NSTextField *statusText;
	
	IBOutlet NSSearchField* searchItemView;
	
	IBOutlet id preferencesListURL;
	IBOutlet id preferencesAddOnsDir;
	
    IBOutlet id mainWindow;
    IBOutlet id prefsWindow;
	
	PluginManager *pluginManager_;
	Notifications *notifications_;

}
- (IBAction)InstallPlugins:(id)sender;
- (IBAction)UninstallPlugins:(id)sender;
- (IBAction)RescanPlugins:(id)sender;
- (IBAction)initialiseGUI:(id)sender;
- (IBAction)applyProperties:(id)sender;
- (IBAction)resetProperties:(id)sender;
- (IBAction)addonsBrowse:(id)sender;
- (IBAction)selectOutdated:(id)sender;
//- (IBAction)selectAll:(id)sender;
//- (IBAction)selectNone:(id)sender;
//- (IBAction)selectInvert:(id)sender;
- (void) doInit;
- (void) markedUpdate;
- (void) statusUpdate:(NSString*)status;
- (void) setupToolbar;
- (BOOL)checkAddonsDirExists;
@end

@interface PluginManagerController (ToolbarDelegateCategory)

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar
    itemForItemIdentifier:(NSString *)itemIdentifier
    willBeInsertedIntoToolbar:(BOOL)flag;
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar;
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar;
- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem;
@end
